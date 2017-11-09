FROM mdelapenya/lamp:latest
LABEL maintainer="mdelapenya@gmail.com"

RUN rm -fr /app
COPY . /app
COPY .docker /app/.docker
COPY .workflow.properties /root/
RUN mv /app/.docker/mysql-setup.sh /mysql-setup.sh \
    && /app/.docker/change-wp-url.sh

VOLUME /app/wp-content
