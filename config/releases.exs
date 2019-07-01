# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
import Config

config :mj, Mj.Repo,
  # ssl: true,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

config :mj, MjWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :mj, MjWeb.Guardian,
  secret_key: System.fetch_env!("JWT_SECRET_KEY")
