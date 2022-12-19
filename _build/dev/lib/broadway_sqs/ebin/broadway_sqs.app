{application,broadway_sqs,
             [{applications,[kernel,stdlib,elixir,logger,broadway,ex_aws_sqs,
                             nimble_options,telemetry,saxy]},
              {description,"A SQS connector for Broadway"},
              {modules,['Elixir.BroadwaySQS.ExAwsClient',
                        'Elixir.BroadwaySQS.Options',
                        'Elixir.BroadwaySQS.Producer',
                        'Elixir.BroadwaySQS.SQSClient']},
              {registered,[]},
              {vsn,"0.7.2"}]}.