FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    flex

COPY example.txt example.txt
COPY mortal-kombat.l mortal-kombat.l
COPY Makefile Makefile

RUN flex mortal-kombat.l
RUN gcc lex.yy.c -o mortal-kombat -ll

RUN ./mortal-kombat < example.txt