#!/bin/bash

readonly IMAGE='ghcr.io/openbao/openbao-ubi:2.5.1@sha256:f9fca77995fa0956b203c8f6eabc8bc15e7af1a817a938f89bca1645ed55bac5'

main() {
    local -r SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    mkdir -p "${SCRIPT_PATH}"/{data,logs,.plugins}

    container_run_opts=(
        --rm
        --name openbao
        --volume "${SCRIPT_PATH}/logs:/openbao/logs"
        --volume "${SCRIPT_PATH}/data:/openbao/data"
        --volume "${SCRIPT_PATH}/.plugins:/openbao/plugins"
        --volume "${SCRIPT_PATH}/config:/openbao/config:ro"
        --volume "${SCRIPT_PATH}/aws:/home/openbao/.aws:ro"
        --env AWS_DEFAULT_REGION=ap-northeast-2
        --env AWS_EC2_METADATA_DISABLED=true
        --publish 127.0.0.1:8200:8200
    )

    (set -x; container run "${container_run_opts[@]}" "${IMAGE}" "$@")
    return $?
}

main "$@"
exit $?
