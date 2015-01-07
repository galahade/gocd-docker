FROM phusion/baseimage:0.9.5

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get update && apt-get install -y -q unzip java7-runtime-headless git
# Due to a bug, it looks like you cannot create a pipeline if you're physically located west of the server. Hmm. :(
RUN echo Pacific/Samoa > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir /etc/service/go-server
ADD go-common-scripts.sh /etc/service/go-server/go-common-scripts.sh
ADD go-server-start.sh /etc/service/go-server/run

RUN mkdir /etc/service/go-agent
ADD go-common-scripts.sh /etc/service/go-agent/go-common-scripts.sh
ADD go-agent-start.sh /etc/service/go-agent/run

ADD http://download.go.cd/gocd-deb/go-server-14.4.0-1356.deb /tmp/go-server.deb
ADD http://download.go.cd/gocd-deb/go-agent-14.4.0-1356.deb /tmp/go-agent.deb

WORKDIR /tmp
RUN dpkg -i /tmp/go-server.deb
RUN dpkg -i /tmp/go-agent.deb
RUN sed -i -e 's/DAEMON=Y/DAEMON=N/' /etc/default/go-server /etc/default/go-agent
RUN echo 'export GO_SERVER_SYSTEM_PROPERTIES="-DpluginLocationMonitor.sleepTimeInSecs=1"' >>/etc/default/go-server
EXPOSE 8153 8154

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
