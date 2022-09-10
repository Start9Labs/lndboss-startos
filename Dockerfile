FROM --platform=linux/arm64/v8 alexbosworth/balanceofsatoshis as bos

FROM --platform=linux/arm64/v8 niteshbalusu/lndboss as lndboss

USER root

ENV BOS_DEFAULT_SAVED_NODE=embassy
ENV PATH "/app:$PATH"

COPY --from=bos /app/ /app/ 

ADD credentials.json /credentials.json
RUN mkdir -p /root/.bos/embassy && chmod -R a+x /root/.bos && mv /credentials.json /root/.bos/embassy/credentials.json && chmod a+x /root/.bos/embassy/credentials.json

ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
ADD ./scripts/check-web.sh /usr/local/bin/check-web.sh
RUN chmod a+x /usr/local/bin/*.sh
