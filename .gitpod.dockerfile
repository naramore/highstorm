FROM gitpod/workspace-full

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
    && dpkg -i erlang-solutions_2.0_all.deb \
    && apt-get update \
    && apt-get install esl-erlang -y \
    && apt-get install elixir -y
RUN mix do local.hex --force, local.rebar --force
RUN wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 -q -O /usr/local/bin/earthly \
    && chmod +x /usr/local/bin/earthly \
    && /usr/local/bin/earthly bootstrap
