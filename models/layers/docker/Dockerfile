ARG SSHD_LAYER_IMG
ARG _DOCKER_LOCAL_IMG

FROM ${_DOCKER_LOCAL_IMG} AS docker_img
FROM ${SSHD_LAYER_IMG}

ARG BIN_PATH
ARG _DOCKER_PLUGINS_PATH
COPY --from=docker_img ${BIN_PATH}/ ${BIN_PATH}/
COPY --from=docker_img ${_DOCKER_PLUGINS_PATH}/ ${_DOCKER_PLUGINS_PATH}/

ARG CHECK_ENTRYPOINT_PATH
ARG DOCKLE_DOWNLOAD_URL
ARG DOCKLE_LAYER_TAG
ARG ENTRYPOINTD_PATH
ARG HTTP_DOCKER_TARGET
ARG NET
ARG REGBOT_URL
ARG REGCTL_URL
ARG REGISTRY_TARGET
ARG REGSYNC_URL
ARG TCP_BUILDKIT_TARGET
ARG TCP_DOCKER_TARGET
ARG XEPHYR_DISPLAY
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    pkg='docker-bash-completion'
    apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community ${pkg}
    wget -q -O "${BIN_PATH}/regbot" "${REGBOT_URL}" https://github.com/regclient/regclient/releases/latest/download/regbot-linux-amd64
    wget -q -O "${BIN_PATH}/regctl" "${REGCTL_URL}" https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64
    wget -q -O "${BIN_PATH}/regsync" "${REGSYNC_URL}" https://github.com/regclient/regclient/releases/latest/download/regsync-linux-amd64
    chmod 0755 "${BIN_PATH}/regbot" "${BIN_PATH}/regctl" "${BIN_PATH}/regsync"
    gz="dockle_${DOCKLE_LAYER_TAG}_Linux-64bit.tar.gz"
    tmp_gz="/tmp/${gz}"
    tmp_dockle='/tmp/dockle'
    wget -q -O "${tmp_gz}" "${DOCKLE_DOWNLOAD_URL}/v${DOCKLE_LAYER_TAG}/${gz}"
    mkdir -p "${tmp_dockle}"
    tar -zxvf "${tmp_gz}" -C "${tmp_dockle}"
    mv "${tmp_dockle}/dockle" "${BIN_PATH}"
    rm -rf "${tmp_gz}" "${tmp_dockle}"
    builder='remote-builder'
    docker buildx create --name "${builder}" --driver remote "${TCP_BUILDKIT_TARGET}"
    docker buildx use --global "${builder}"
    cat << TEMPLATING > /etc/profile.d/99env.sh
main ()
{
  DOCKER_HOST='${TCP_DOCKER_TARGET}'
  XEPHYR_DISPLAY='${XEPHYR_DISPLAY}'

  export DOCKER_HOST XEPHYR_DISPLAY
}

main
TEMPLATING
    _apk="$(command -v apk)"
    _docker="$(command -v docker)"
    _dockle="$(command -v dockle)"
    _regbot="$(command -v regbot)"
    _regctl="$(command -v regctl)"
    _regsync="$(command -v regsync)"
    _wget="$(command -v wget)"
    registry_entrypoint="${ENTRYPOINTD_PATH}/98registry.sh"
    cat << TEMPLATING > "${registry_entrypoint}"
#! /bin/sh

main ()
{
  set -eux
  ${_regctl} registry set --tls=disabled "${REGISTRY_TARGET}"
}

main
TEMPLATING
    cat << TEMPLATING > "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check docker client is available
  DOCKER_HOST=${TCP_DOCKER_TARGET} ${_docker} version

  # check docker socket is reachable
  ${_wget} -q -O- '${HTTP_DOCKER_TARGET}/version'

  # check docker plugins
  ${_docker} buildx version
  ${_docker} compose version

  # check dockle availability
  ${_dockle} --version

  # check regclient is available
  ${_regbot} version
  ${_regctl} version
  ${_regsync} version

  # check packages are available
  for _pkg in ${pkg}
  do
    ${_apk} info --installed "\${_pkg}"
  done
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}" "${registry_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
