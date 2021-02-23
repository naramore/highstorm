# Update the VARIANT arg in docker-compose.yml to pick an Elixir version: 1.9, 1.10, 1.10.4
ARG VARIANT=latest
FROM elixir:${VARIANT}

# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Options for common package install script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.158.0/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="c71ca121f2ae9fe59316651789c4c21c21f7dafb4d0ff67e9d9b32ca446f797f"

# [Optional] Settings for Phoenix
ARG PHOENIX_VERSION="1.5.4"

# [Optional] Settings for installing Node.js.
ARG INSTALL_NODE="true"
ARG NODE_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/node-debian.sh"
ARG NODE_SCRIPT_SHA="dev-mode"
ARG NODE_VERSION="lts/*"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true
ENV PATH=${NVM_DIR}/current/bin:${PATH}

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y --no-install-recommends \
    curl=7.64.0-4+deb10u1 \
    ca-certificates=20200601~deb10u2 2>&1 \
  && curl -sSL ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
  && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
  #
  # [Optional] Install Node.js for use with web applications
  && if [ "$INSTALL_NODE" = "true" ]; then \
  curl -sSL ${NODE_SCRIPT_SOURCE} -o /tmp/node-setup.sh \
  && ([ "${NODE_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/node-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/node-setup.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}"; \
  fi \
  #
  # Install dependencies
  && apt-get install -y --no-install-recommends build-essential=12.6 \
  #
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh /tmp/node-setup.sh

ENV MIX_HOME=/home/${USERNAME}/.mix
RUN su ${USERNAME} -c "mix local.hex --force \
  && mix local.rebar --force \
  && mix archive.install --force hex phx_new ${PHOENIX_VERSION}"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
      inotify-tools=3.14-7 \
      git=1:2.20.1-2+deb10u3 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
  
# [Optional] Settings for installing docker client
ARG DOCKER_VERSION=20.10.3
ARG DOCKER_SOURCE="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"
    
# [Optional] Uncomment this section to intall docker client (w/o starting daemon)
RUN curl -sSL ${DOCKER_SOURCE} -o /tmp/docker-${DOCKER_VERSION}.tgz \
    && tar xzvf /tmp/docker-${DOCKER_VERSION}.tgz -C /tmp \
    && mv /tmp/docker/* /usr/bin/ \
    && rm -f /tmp/docker-${DOCKER_VERSION}.tgz \
    && groupadd docker \
    && usermod -aG docker root \
    && usermod -aG docker ${USERNAME}
    
# [Optional] Settings for installing earthly.dev
ARG EARTHLY_VERSION=v0.5.2
ARG EARTHLY_SOURCE="https://github.com/earthly/earthly/releases/download/${EARTHLY_VERSION}/earthly-linux-amd64"
ARG EARTHLY_GLOBAL_RUNPATH
    
# [Optional] Uncomment this section to intall earthly.dev
RUN curl -sSL ${EARTHLY_SOURCE} -o /usr/local/bin/earthly \
    && chmod 755 /usr/local/bin/earthly \
    && /usr/local/bin/earthly bootstrap
RUN su ${USERNAME} -c "earthly config global.run_path ${EARTHLY_GLOBAL_RUNPATH}"
RUN mkdir -p ${EARTHLY_GLOBAL_RUNPATH}

# [Optional] Uncomment this line to install additional package.
# RUN mix ...

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
