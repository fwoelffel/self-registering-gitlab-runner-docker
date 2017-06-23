FROM gitlab/gitlab-runner:alpine
VOLUME ["/home/gitlab-runner/"]
ADD start.sh /
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
