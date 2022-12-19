defmodule MyApp.MyBroadway do
  use Broadway

  require Logger

  alias Broadway.Message

  def start_link(_opts) do
    producer = Application.fetch_env!(:my_app, :producer)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: producer,
      processors: [
        default: [
          concurrency: 100,
          max_demand: 1
        ]
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 2000,
          concurrency: 10
        ]
      ]
    )
  end

  @impl true
  def handle_message(_processor, %Message{data: data} = message, _context) do
    data
    |> case do
      "process_fail" ->
        message |> Message.failed("Message.failed/2 in handler")

      "process_throw" ->
        throw("throwed error message")

      "process_raise" ->
        raise("raised error message")

      _ ->
        message
    end
  end

  @impl true
  def handle_batch(_batcher, messages, _batch_info, _context) do
    updated_messages =
      messages
      |> Enum.map(fn message ->
        message.data
        |> case do
          "batch_fail" ->
            message |> Message.failed("Message.failed/2 in batch")

          "batch_throw" ->
            throw("batch throwed error message")

          "batch_raise" ->
            raise("batch raised error message")
        end
      end)

    IO.inspect(updated_messages,
      label: "Got batch of finished jobs from processors, sending ACKs to SQS as a batch."
    )

    updated_messages
  end

  @impl true
  def handle_failed(messages, _context) do
    messages
    |> Enum.each(fn %Message{status: status} ->
      IO.inspect(status, label: "MyBroadway received failed message")

      Logger.error("MyBroadway received failed message with status: #{inspect(status)}")
    end)

    messages
  end
end
