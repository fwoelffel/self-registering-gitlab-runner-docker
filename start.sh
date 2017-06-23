#!/bin/bash
set -e

export CI_USER=gitlab-runner
export WORKING_DIR=/home/${CI_USER}/${HOSTNAME}

# Verify existing configuration
if [[ -f ${WORKING_DIR}/config.toml ]]
then
  gitlab-runner verify --delete --config ${WORKING_DIR}/config.toml
  runner_count=$(($(gitlab-runner list --config ${WORKING_DIR}/config.toml &> .gitlab-runner-list && cat .gitlab-runner-list | wc -l && rm .gitlab-runner-list)-1))
  if [[ $DEBUG ]]
  then
    echo "There is ${runner_count} runner in the config.toml"
  fi
fi

if [[ ! -f ${WORKING_DIR}/config.toml || ${runner_count} -lt 1 ]]
then
  # Register a new register if there is none yet
  export REGISTER_NON_INTERACTIVE=true
  export RUNNER_EXECUTOR=docker
  export RUNNER_TAG_LIST=${RUNNER_EXECUTOR},${RUNNER_TAG_LIST}
  export DOCKER_PRIVILEGED=true
  # Verifying some env var existence
  : "${CI_SERVER_URL:?CI_SERVER_URL has to be set and non-empty}"
  : "${REGISTRATION_TOKEN:?REGISTRATION_TOKEN has to be set and non-empty}"
  : "${DOCKER_IMAGE:?DOCKER_IMAGE has to be set and non-empty}"
  # Setting $RUNNER_NAME if none defined
  export RUNNER_NAME="${RUNNER_NAME:-Running on ${HOSTNAME}}"
  gitlab-runner register --config ${WORKING_DIR}/config.toml
fi

if [[ $CONCURRENCY ]]
then

  if [[ $DEBUG ]]
  then
    echo "Updating the gitlab-runner service concurrency to $CONCURRENCY..."
  fi

  cat ${WORKING_DIR}/config.toml | sed "s/concurrent =.*/concurrent = $CONCURRENCY/" > ${WORKING_DIR}/config.toml.updated
  mv ${WORKING_DIR}/config.toml.updated ${WORKING_DIR}/config.toml
  echo "Updated"
fi

if [[ $DEBUG ]]
then
  echo "Printing the config.toml file..."
  cat ${WORKING_DIR}/config.toml
  echo "Printed"
fi

export RUNNER_TOKEN=$(grep token /etc/gitlab-runner/config.toml | awk '{print $3}' | tr -d '"')

# Start the Gitlab Runner
gitlab-runner run \
  --user=${CI_USER} \
  --working-directory=${WORKING_DIR} \
  --config ${WORKING_DIR}/config.toml
