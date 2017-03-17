FROM fedora

RUN dnf install -y 'dnf-command(copr)' && \
    dnf copr -y enable jkonecny/kakoune && \
    dnf install -y kakoune

