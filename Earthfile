ARG ELIXIR_DEFAULT=1.11.3
ARG OTP_DEFAULT=23.2.4
ARG OS_DEFAULT=alpine-3.13.1
ARG REVIEWDOG_DEFAULT=v0.11.0
ARG REVIEWDOG_REPORTER=local
ARG REVIEWDOG_GITHUB_API_TOKEN
ARG CODECOV_TOKEN

# TODO: speedup +static w/ shared caching (https://github.com/earthly/earthly/issues/574)
# TODO: until then, add inline caching for _build/, deps/, & priv/plts (https://docs.earthly.dev/guides/shared-cache#inline-cache)
# TODO: add conditional `--push` to reviewdog calls (https://github.com/earthly/earthly/issues/779)
# TODO: cleanup +reviewdog-setup and add +reviewdog-run (https://github.com/earthly/earthly/issues/581)

all:
    BUILD +all-test
    BUILD +all-analyses

all-test:
    BUILD --build-arg ELIXIR=$ELIXIR_DEFAULT --build-arg OTP=$OTP_DEFAULT +test
    
all-analyses:
    BUILD --build-arg ELIXIR=$ELIXIR_DEFAULT --build-arg OTP=$OTP_DEFAULT +analyses

test:
    FROM +test-setup
    RUN mix test --stale --trace
    
analyses:
    BUILD +coverage
    BUILD +lint
    BUILD +format
    BUILD +static
    BUILD +lint-docker

lint-docker:
    FROM --build-arg BUILD_POINT=hadolint/hadolint:v1.22.1-alpine +reviewdog-setup
    COPY .devcontainer/Dockerfile .
    RUN reviewdog -reporter=${REVIEWDOG_REPORTER} -filter-mode=nofilter -runners=hadolint -fail-on-error=true
    
coverage:
    FROM +test-setup
    RUN apk add --update-cache --no-progress git curl bash findutils
    RUN mix coveralls.json
    RUN --push bash <(curl -s https://codecov.io/bash) -t ${CODECOV_TOKEN}
  
lint:
    FROM --build-arg BUILD_POINT=+test-setup +reviewdog-setup
    COPY .credo.exs .
    RUN reviewdog -reporter=${REVIEWDOG_REPORTER} -filter-mode=nofilter -runners=credo -fail-on-error=true
    
format:
    FROM +test-setup
    COPY .formatter.exs .
    RUN mix format --check-formatted

static:
    FROM +test-setup
    RUN mix dialyzer --plt
    SAVE ARTIFACT priv/plts/*.plt* /plts AS LOCAL priv/plts
    COPY .dialyzer_ignore.exs .
    RUN mix dialyzer

reviewdog-setup:
  ARG BUILD_POINT
  FROM $BUILD_POINT
  ENV REVIEWDOG_GITHUB_API_TOKEN=${REVIEWDOG_GITHUB_API_TOKEN}
  RUN apk add --no-cache curl; \
      curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin v0.11.0; \
      apk del --no-network curl
  COPY .reviewdog.yml .

test-setup:
  FROM +deps-setup
  COPY --dir lib test priv ./
  RUN mix compile --warnings-as-errors

deps-setup:
   FROM +deps-check
   ENV MIX_ENV=test
   RUN mix deps.get
   RUN mix deps.compile

deps-check:
    FROM +setup-base
    COPY mix.exs .
    COPY mix.lock .
    RUN mix do local.hex --force, local.rebar --force
    RUN cp mix.lock mix.lock.orig && \
        mix deps.get && \
        mix deps.unlock --check-unused && \
        diff -u mix.lock.orig mix.lock && \
        rm mix.lock.orig
   
setup-base:
   ARG ELIXIR=$ELIXIR_DEFAULT
   ARG OTP=$OTP_DEFAULT
   FROM hexpm/elixir:$ELIXIR-erlang-$OTP-$OS_DEFAULT
   RUN apk add --no-progress --update git build-base
   ENV ELIXIR_ASSERT_TIMEOUT=10000
   WORKDIR /src
