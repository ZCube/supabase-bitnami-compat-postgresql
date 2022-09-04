FROM ghcr.io/zcube/bitnami-compat/postgresql:14

USER root

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install --yes --no-install-recommends \
    make \
    git \
    gcc \
    libc6-dev \
    postgresql-server-dev-14 \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
  cd /tmp && \
  git clone https://github.com/michelp/pgjwt.git && \
  git clone https://github.com/eulerto/wal2json.git && \
  cd pgjwt && make install && cd /tmp && \
  cd wal2json && make && make install && cd /tmp && \
  \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -r /var/lib/apt/lists /var/cache/apt/archives

RUN install_packages make git gcc libc6-dev

USER 1001
