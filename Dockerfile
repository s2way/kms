FROM node:4

MAINTAINER Telo <joaotelo.nh@hotmail.com>

COPY . /src

EXPOSE 80

WORKDIR /src
RUN npm install

CMD ["npm", "start"]