FROM ghcr.io/zcube/bitnami-compat/postgresql:14

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y ansible sudo git flex bison make postgresql-server-dev-14 && \
    apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade && \
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
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

USER 1001
