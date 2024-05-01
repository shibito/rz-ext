import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :banking_web, BankingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Jxu78n23vkW4BXX0oAZlwicebPIygFJavcmdOg/sKUP6pDqaA3AD5cQE4rjVjYxB",
  server: false
