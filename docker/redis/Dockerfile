FROM redis:7-alpine

RUN apk add --no-cache openssl bash

COPY start.sh /usr/bin/
RUN chmod +x /usr/bin/start.sh

# Give root a random password
RUN echo "root:$(openssl rand -base64 12)" | chpasswd

USER redis
ENTRYPOINT ["start.sh"]
