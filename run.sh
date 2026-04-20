#!/bin/bash

readonly IMAGE='ghcr.io/openbao/openbao-ubi:2.5.3@sha256:49b9911dfaa1d65084ecc415d043d2b18f593c53ff1bd46b4a314fc77d238a26'

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
