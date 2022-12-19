defmodule MyBroadwayTest do
  use ExUnit.Case, async: false

  require Logger

  import ExUnit.CaptureLog

  alias MyApp.MyBroadway
  alias MyLoggerMock
  alias ExAws
  alias ExAws.SQS

  @approximate_waiting_time_for_two_tries 15_000
  @approximate_waiting_time_for_dlq 10_000

  @account_id "000000000000"
  @main_queue_name "main-queue"
  @dlq_name "main-queue-dead-letters"
  @sqs_path "/#{@account_id}/#{@main_queue_name}"

  setup _, do: purge_queues()

  describe "handle_message/3" do
    test "should process message and empty queue" do
      assert_queues_messages()
      send_message_to_sqs("process_message")

      MyBroadway.start_link([])
      :timer.sleep(@approximate_waiting_time_for_two_tries)

      assert_queues_messages()
    end

    test "should populate dlq on fail" do
      test_broadway_pipeline("process_fail", "{:failed, \"Message.failed/2 in handler\"}")
    end

    test "should populate dlq on throw" do
      test_broadway_pipeline("process_throw", "{:throw, \"throwed error message\"")
    end

    test "should populate dlq on raise" do
      test_broadway_pipeline(
        "process_raise",
        "{:error, %RuntimeError{message: \"raised error message\"}"
      )
    end
  end

  describe "handle_batch/4" do
    test "should populate dlq on fail" do
      test_broadway_pipeline("batch_fail", "{:failed, \"Message.failed/2 in batch\"}")
    end

    test "should populate dlq on throw" do
      test_broadway_pipeline("batch_throw", "{:throw, \"batch throwed error message\"")
    end

    test "should populate dlq on raise" do
      test_broadway_pipeline(
        "batch_raise",
        "{:error, %RuntimeError{message: \"batch raised error message\"}"
      )
    end
  end

  defp test_broadway_pipeline(message_text, error_substring) do
    assert_queues_messages()
    send_message_to_sqs(message_text)

    fail_log_occurances =
      fn ->
        MyBroadway.start_link([])

        :timer.sleep(@approximate_waiting_time_for_two_tries)
      end
      |> count_str_occurance_in_log(error_substring)

    assert 2 = fail_log_occurances
    :timer.sleep(@approximate_waiting_time_for_dlq)

    assert_queues_messages(message_text)
  end

  defp count_str_occurance_in_log(fun, str) do
    fun
    |> capture_log()
    |> String.split(str)
    |> length()
    |> then(&(&1 - 1))
  end

  defp send_message_to_sqs(msg) do
    @sqs_path
    |> SQS.send_message(msg)
    |> ExAws.request()
  end

  defp receive_message_from_queue(queue_name) do
    "/#{@account_id}/#{queue_name}"
    |> ExAws.SQS.receive_message()
    |> ExAws.request()
  end

  defp purge_queues do
    [@dlq_name, @main_queue_name]
    |> Enum.each(fn queue_name ->
      "/#{@account_id}/#{queue_name}"
      |> ExAws.SQS.purge_queue()
      |> ExAws.request()
    end)
  end

  defp assert_queues_messages(expected_dlq_message \\ nil) do
    assert {:ok, %{body: %{messages: []}}} = receive_message_from_queue(@main_queue_name)

    case expected_dlq_message do
      nil ->
        assert {:ok, %{body: %{messages: []}}} = receive_message_from_queue(@dlq_name)

      message_text ->
        assert {:ok, %{body: %{messages: [%{body: ^message_text}]}}} =
                 receive_message_from_queue(@dlq_name)
    end
  end
end
