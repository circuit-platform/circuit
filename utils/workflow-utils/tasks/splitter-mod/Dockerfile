FROM alpine:3.12.0

RUN apk add \
		httpie=2.1.0-r0 \
		bind-tools=9.14.12-r0 \
		jq=1.6-r1

COPY run.sh /opt/circuit/run.sh
RUN chmod +x /opt/circuit/run.sh

ENTRYPOINT ["/opt/circuit/run.sh"]