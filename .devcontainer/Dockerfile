FROM scilus/scilus:2.0.2

ARG NFTEST_VERSION

ENV NODE_MAJOR=18
ENV NFTEST_VERSION=${NFTEST_VERSION:-0.9.0-rc1}

RUN apt update && apt install -y \
        curl \
        git \
        python3-venv \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install pipx && \
    python3 -m pipx ensurepath && \
    pipx install poetry

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - &&\
    apt-get install -y nodejs

WORKDIR /
RUN mkdir -p nf-test/bin

WORKDIR /nf-test/bin/
RUN curl -fsSL https://code.askimed.com/install/nf-test | bash -s ${NFTEST_VERSION}
ENV PATH=$PATH:/nf-test/bin
