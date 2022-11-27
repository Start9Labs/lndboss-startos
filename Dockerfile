FROM alexbosworth/balanceofsatoshis as bos-builder

FROM niteshbalusu/lndboss:v2.11.0 as lndboss

# arm64 or amd64
ARG PLATFORM
ARG ARCH

USER root
RUN apk add tini bash


ENV BOS_DATA_PATH '/root/.bosgui'
ENV BOS_DEFAULT_SAVED_NODE 'start9'
ENV BOS_DEFAULT_LND_SOCKET 'lnd.embassy:10009'
ENV PATH "/app:$PATH"

COPY --from=bos-builder /app/ /app/ 

ADD docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
ADD actions/reset-users.sh /usr/local/bin/reset_users.sh
RUN chmod a+x /usr/local/bin/*.sh
