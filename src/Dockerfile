FROM ubuntu:21.04

ADD . /opt/
WORKDIR /opt/

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install python3-pip dnsutils -yyqq
RUN pip3 install -r requirements.txt

ENTRYPOINT ["./script.py"]
