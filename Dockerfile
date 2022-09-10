FROM --platform=linux/arm64/v8 alexbosworth/balanceofsatoshis as bos

FROM --platform=linux/arm64/v8 niteshbalusu/lndboss as lndboss

USER root

ENV BOS_DATA_PATH '/root/.bosgui'
ENV BOS_DEFAULT_SAVED_NODE 'start9'
ENV BOS_DEFAULT_LND_SOCKET 'lnd.embassy:10009'
ENV PATH "/app:$PATH"

COPY --from=bos /app/ /app/ 

RUN mkdir -p /root/.bos/embassy && chmod -R a+x /root/.bos
RUN mkdir -p /root/.bosgui/start9 && chmod -R a+x /root/.bosgui/start9

ADD /docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
ADD /check-web.sh /usr/local/bin/check-web.sh
RUN chmod a+x /usr/local/bin/*.sh
