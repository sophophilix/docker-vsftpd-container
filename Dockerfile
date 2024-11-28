FROM alpine:3.20.0
ENV FTP_USER=vsftp-user \
	FTP_PASS=yourpass \
	GID=601 \
	UID=601

RUN apk add --no-cache --update \
	vsftpd==3.0.5-r2

COPY [ "/app/vsftpd.conf", "/etc" ]
COPY [ "/app/docker-entrypoint.sh", "/" ]
RUN chmod +x docker-entrypoint.sh


CMD [ "/usr/sbin/vsftpd" ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE 20/tcp 21/tcp 40000-40009/tcp
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD echo "user $FTP_USER $FTP_PASS" | ftp -n localhost 21 || exit 1
