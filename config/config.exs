import Config

for config <- "#{config_env()}.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  import_config config
end
