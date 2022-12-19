# Broadway SQS example integration

This repo contains example broadway pipeline implementation with different kinds of errors in `handle_message/3` and `handle_batch/4` with tests correspondent to each error case. Those tests rely on [dockerized](https://hub.docker.com/r/softwaremill/elasticmq-native/) SQS-compatible queue implementation [ElasticMQ](https://github.com/softwaremill/elasticmq).


## How to run

Make sure you have docker installed and it is compatible with `3.6 docker-compose.yml`

To run tests:
```
$ make test-shell
$ mix test
$ exit
```

To bring docker-compose down:
```
$ make down
```

You can also use provided [.devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) setup for local development.

## How does it work

This example relies on [BroadwaySQS.Producer](https://github.com/dashbitco/broadway_sqs) which by default sets up SQS-compatible [acknowledger](https://hexdocs.pm/broadway/Broadway.Acknowledger.html) [BroadwaySQS.ExAwsClient](https://github.com/dashbitco/broadway_sqs/blob/main/lib/broadway_sqs/ex_aws_client.ex).

Test example sets up/dependent on 2 queues: `main-queue` and its DLQ `main-queue-dead-letters` which is used after 2 subsequent retries.