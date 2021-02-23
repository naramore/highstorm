> **HIGHLY EXPERIMENTAL AND IN ACTIVE DEVELOPEMENT: USE AT YOUR OWN RISK**

# Highstorm

Datalog, git-style data archival, pathom, and other related ideas for Elixir.

Assume the following:

- undocumented
- untested
- unfinished
- not intended for production use

More akin to a scratchpad or and incubator for ideas.

## Development Setup

> All of these setup steps were tested on MacOS 11.2.1 on 2/23/2021

To start your Phoenix server:

  * Install Git: https://git-scm.com/downloads (unnecessary if using Gitpod)
  * Install Visual Studio Code: https://code.visualstudio.com/Download (unnecessary if using Gitpod)
  * Setup Development Environment (see options below, local, devcontainer, gitpod)
  * Install dependencies with `mix deps.get`
  * Start database: `docker-compose up -d db` (unnecessary if using devcontainer)
  * Create and migrate your database with `mix do ecto.create, ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install && cd ..`
  * Start Phoenix endpoint with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Local

- [Install Elixir](https://elixir-lang.org/install.html)
- `mix do local.hex --force, local.rebar --force`
- `mix archive.install hex phx_new`
- Clone Repo: `git clone git@github.com:naramore/highstorm.git`
- Open Project in VSCode
- Install all Recommended VSCode Extensions when prompted

### devcontainer

> NOTE: if you have issues with ElixirLS losing connection, add more memory to Docker

- [Install Docker](https://docs.docker.com/engine/install/)
- Clone Repo: `git clone git@github.com:naramore/highstorm.git`
- Open Project in VSCode
- Create environment file: `echo "EARTHLY_GLOBAL_RUNPATH=${HOME}/.earthly" > .env`
- [Install Remote - Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Click the Remote "Quick Access" status bar item (green, bottom-left corner) and select: `Remote-Containers: Reopen in Container`, or select the `Reopen in Container` when prompted by VSCode.
- Wait for container to build and load...

### Gitpod

- https://gitpod.io#https://github.com/naramore/highstorm
- login to GitHub account
- wait for the dev environment to build / load...

## CI/CD

Install [Docker](https://docs.docker.com/engine/install/) and [earthly.dev](https://earthly.dev/get-earthly)

- Run analyses: `earthly +analyses`
- Run tests: `earthly +test`

## TODO

- [x] meddle (interceptors)
- [ ] oath (data contracts/specifications)
- [x] entry (`Access` shortcuts)
- [ ] stream_data_utils
  - [ ] investigate? https://github.com/whatyouhide/stream_data/issues/97
  - [ ] utilities: functions, datetimes, shrinking
  - [ ] stateful: fsm, statem, component, cluster, dynamic_cluster
  - [ ] targetted: target, sa
  - [ ] misc: suite, symbolic, temporal, mocking, grammar
- [ ] diff (`List.myers_difference/3`-ish for all data)
  - types:
    - `String`      -> `String.myers_difference/2`
    - `List`        -> `List.myers_difference/3`
    - `MapSet`      -> `{a_only, b_only, both}` (treat elements atomically)
    - `Tuple`       -> `List.myers_difference/3`
    - `Map`         -> ???
    - `Keyword`     -> similar to `Map`, but ordered?
    - Improper List -> `{proper_myers_difference, improper_diff}`
    - Struct        -> `{struct, map_only_a, map_only_b, map_both}`
    - Any           -> ???
    - Others?       -> `Range`, `Date.Range`, `Date`, `Time`, (other time related structs),
- [ ] annex (git)
- [ ] delve (pathom)
- [ ] basis (datalog)
- [ ] ivy (ETS + datalog)

### Followups

- [ ] dtabs (see https://twitter.github.io/finagle/guide/Names.html)
- [ ] datafy + nav + REBL
- [ ] digraph_ui (i.e. phoenix liveview for `:digraph` display)
- [ ] delve inspect (i.e. phoenix liveview UI similar to GraphIQL, GraphQLPlayground, or pathom_viz)
