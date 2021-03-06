#!/usr/bin/env bash
GIT_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

PROJECT_ENV="${GIT_ROOT}/project.env"
DOCKERFILE="${SCRIPT_DIR}/tf_tools.dockerfile"

USER_NAME="$(id -un)"
GROUP_NAME="$(id -gn)"

CONTAINER_NAME=$(basename "${GIT_ROOT}")
CONTAINER_VERSION="latest"
CONTAINER_TAG="${CONTAINER_NAME}:${CONTAINER_VERSION}"
CONTAINER_HOME="/opt/${USER_NAME}"
CONTAINER_SHELL="bash"

echo "Sourcing project env ${PROJECT_ENV}"
source ${PROJECT_ENV}

echo "GIT_ROOT         : ${GIT_ROOT}"
echo "SCRIPT_DIR       : ${SCRIPT_DIR}"
echo "CONTAINER_NAME   : ${CONTAINER_NAME}"
echo "CONTAINER_VERSION: ${CONTAINER_VERSION}"
echo "CONTAINER_TAG    : ${CONTAINER_TAG}"
echo "CONTAINER_HOME   : ${CONTAINER_HOME}"
echo "CONTAINER_SHELL  : ${CONTAINER_SHELL}"
echo "USER_NAME        : ${USER_NAME}"
echo "GROUP_NAME       : ${GROUP_NAME}"
echo "AWS_PROFILE      : ${AWS_PROFILE}"

case "$1" in
  build)
    echo "Building the container"
    docker build \
      --build-arg USER_NAME="${USER_NAME}" \
      --build-arg GROUP_NAME="${GROUP_NAME}" \
      --build-arg AWS_PROFILE="${AWS_PROFILE}" \
      --tag "${CONTAINER_TAG}" \
      --file "${DOCKERFILE}" \
      "${GIT_ROOT}"
    ;;
  run)
    CONTAINER_ID=$(docker ps -q -f name="${CONTAINER_NAME}")
    if [[ -n ${CONTAINER_ID} ]]; then
      echo "Running inside existing container ${CONTAINER_ID}"
      docker exec \
        --interactive \
        --tty \
        "${CONTAINER_NAME}" \
        "${CONTAINER_SHELL}"
    else
      echo "Running inside new container"
      docker run \
        --interactive \
        --tty \
        --rm \
        --volume "${HOME}/.aws:${CONTAINER_HOME}/.aws" \
        --volume "${GIT_ROOT}:${CONTAINER_HOME}/src" \
        --name "${CONTAINER_NAME}" \
        "${CONTAINER_TAG}" \
        "${CONTAINER_SHELL}"
      fi
    ;;
  *)
    echo "Usage: $0 {build|run}"
    ;;
esac
