#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

JUMP_AREA_NET='jump-area'
PROXIFIED_SOCKET_NET='proxified-socket'

SUBNET_MASK='/24'

PROXY_PORT='2363'

NET_PFX='172.17'
PROXIFIED_SOCKET_PFX="${NET_PFX}.1"
JUMP_AREA_PFX="${NET_PFX}.2"

PROXIFIED_SOCKET_SUB="${PROXIFIED_SOCKET_PFX}.0${SUBNET_MASK}"
JUMP_AREA_SUB="${JUMP_AREA_PFX}.0${SUBNET_MASK}"

# shellcheck disable=2153
# SC2153: Possible misspelling => it is not, we really want PROXY_ID here
_DOCKER_HOST="${PROXY_ID}:${PROXY_PORT}"
HTTP_DOCKER_HOST="http://${_DOCKER_HOST}"
TCP_DOCKER_HOST="tcp://${_DOCKER_HOST}"

PROXIFIED_SOCKET_GATEWAY_IP="${PROXIFIED_SOCKET_PFX}.1"
JUMP_AREA_GATEWAY_IP="${JUMP_AREA_PFX}.1"
PROXY_IP="${PROXIFIED_SOCKET_PFX}.2"
COLLECTOR_IP="${PROXIFIED_SOCKET_PFX}.3"
CONTROLLER_IP="${PROXIFIED_SOCKET_PFX}.4"
