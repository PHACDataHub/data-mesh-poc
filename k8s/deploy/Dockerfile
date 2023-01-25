FROM alpine

RUN \
    echo -e '#!/bin/bash\nexec $@' > /usr/bin/sudo && chmod +x /usr/bin/sudo && \
    apk add --no-cache bash shadow

WORKDIR /src

COPY . .

RUN \
    mv data /data && \
    mv kafka/plugins /plugins

CMD ["./k8s/deploy/seed.sh"]
