FROM ghcr.io/zcube/bitnami-compat/postgresql:14

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y libc++1 libc6 && \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install --yes --no-install-recommends \
      postgresql-server-dev-14 \
      git \
      flex \
      bison \
      make \
      ansible \
      sudo \
      gcc \
      libc6-dev \
      && \
	  rm -rf /var/lib/apt/lists/*; \
    cd /tmp && \
    git clone -b "stable" "https://gitlab.com/dalibo/postgresql_anonymizer" && \
    cd postgresql_anonymizer && make extension && make install && cd /tmp && \
    cd /tmp && \
    git clone https://github.com/supabase/postgres && \
    mv postgres/ansible /tmp/ && \
    cd /tmp/ansible && \
    adduser postgres --uid 1001 --gid 0 && \
    addgroup postgres --gid 1001 && \
    ansible-playbook playbook-docker.yml && \
    delgroup postgres && \
    deluser postgres && \
    apt -y autoremove && \
    apt -y autoclean && \
    apt install -y default-jdk-headless locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -r /var/lib/apt/lists /var/cache/apt/archives /tmp/* /var/tmp/*

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

USER 1001
