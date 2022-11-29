import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mantra, MantraWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "VU24ExAY1pvOlR4s/g05FAn45UJd9MaFfwWmFrp3by81bSlB4hUmdTBhMSWQsbQv",
  server: false

# In test we don't send emails.
config :mantra, Mantra.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
