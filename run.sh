#!/bin/bash

readonly IMAGE='ghcr.io/openbao/openbao-ubi:2.4.4@sha256:7a37b89e5315d5472b3dc24b5e02e80c55466a8342a3e07d2ecae92bdc8b4e88'

main() {

    local -r SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    mkdir -p "${SCRIPT_PATH}"/{data,logs}

    container_run_opts=(
        --rm
        --name openbao
        --volume "${SCRIPT_PATH}/logs:/openbao/logs"
        --volume "${SCRIPT_PATH}/data:/openbao/data"
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