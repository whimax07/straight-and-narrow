FROM fedora:latest

RUN dnf install -y \
    micro \
    aspell \
    aspell-en

RUN micro -plugin install aspell

ADD bindings.json /root/.config/micro/
ADD settings.json /root/.config/micro/
