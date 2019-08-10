FROM elixir:1.9

ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /opt/app
ADD . .

RUN mix deps.get
RUN mix release

ENTRYPOINT ["/opt/app/_build/prod/rel/mah/bin/mah", "start"]
