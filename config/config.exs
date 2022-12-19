use Mix.Config

config :ex_aws_sqs, parser: ExAws.SQS.SweetXmlParser

config :ex_aws, :sqs,
  scheme: "http://",
  host: "broadway-sqs-test",
  port: "9324",
  region: "elasticmq"

config :ex_aws,
  access_key_id: "x",
  security_token: "x",
  secret_access_key: "x"

scheme = System.get_env("SQS_SCHEME", "http://")
host = System.get_env("SQS_HOST", "broadway-sqs-test")
port = System.get_env("SQS_PORT", "9324")

access_key_id = System.get_env("AWS_ACCESS_KEY_ID", "some_id")
secret_access_key = System.get_env("AWS_SECRET_ACCESS_KEY", "some_key")

queue_name = System.get_env("AWS_QUEUE_PATH", "main-queue")
account_id = "000000000000"
queue_url = "#{scheme}#{host}:#{port}/#{account_id}/#{queue_name}"

config :my_app,
  producer: [
    concurrency: 4,
    module:
      {BroadwaySQS.Producer,
       queue_url: queue_url,
       config: [
         scheme: scheme,
         host: host,
         port: port,
         access_key_id: access_key_id,
         secret_access_key: secret_access_key
       ]}
  ]

import_config "#{Mix.env()}.exs"
