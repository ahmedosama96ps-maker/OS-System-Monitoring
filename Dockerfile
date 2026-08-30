FROM ubuntu:24.04

WORKDIR /app

RUN apt update && apt install -y \
    procps \
    iproute2 \
    net-tools \
    lm-sensors \
    smartmontools \
    pandoc \
    whiptail \
    pciutils \
    less \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN chmod +x /app/scripts/monitor.sh
RUN chmod +x /app/scripts/dashboard.sh

CMD ["bash", "/app/scripts/monitor.sh"]
