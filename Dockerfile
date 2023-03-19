FROM node:16

WORKDIR /app

RUN npm install express
RUN npm install pm2 -g

COPY ./ ./

EXPOSE 3000

CMD ["pm2-runtime", "index.js", "-i", "0"]