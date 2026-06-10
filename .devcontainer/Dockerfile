FROM gcc:15.2.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gdb \
        git \
        make \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ac-library \
    && curl -L https://github.com/atcoder/ac-library/archive/refs/tags/v1.6.tar.gz \
    | tar -xz --strip-components=1 -C /opt/ac-library

ENV CPLUS_INCLUDE_PATH="/opt/ac-library:${CPLUS_INCLUDE_PATH}"

WORKDIR /workspaces/atcoder

