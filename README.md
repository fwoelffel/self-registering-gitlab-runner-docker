# self-registering-gitlab-runner-docker

## Build

```
docker build -t self-registering-gitlab-runner-docker .
```

## Run

This is only an example command. You should customize it according to your needs.

```
docker run \
  --detach \
  --name gitlab-runner \
  --env CI_SERVER_URL=< your Gitlab CI URL > \
  --env REGISTRATION_TOKEN=< your Gitlab CI registration token > \
  --env RUNNER_ENV="GIT_SSL_NO_VERIFY=1" \
  --env DOCKER_DISABLE_CACHE=true \
  --env DOCKER_IMAGE=true \
  --env CONCURRENCY=1 \
  --env REGISTER_RUN_UNTAGGED=true \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  self-registering-gitlab-runner-docker
```
