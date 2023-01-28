FROM alpine:3.17.1

RUN apk add \
		httpie=3.2.1-r1 \
		bind-tools=9.18.11-r0 \
		jq=1.6-r2

COPY run.sh /opt/circuit/run.sh
RUN chmod +x /opt/circuit/run.sh

ENTRYPOINT ["/opt/circuit/run.sh"]