# THIS IS A SAMPLE IMAGE USED AS A STARTPOINT FOR CONFIGURING A SECURE CONTAINER


#   Pulling the alpine based node.js image with a 'Docker Official Image' tag from Docker Hub
FROM node:alpine AS base

#   Installing dumb-init which prevents node to start with PID 1, because that may lead to conflicts as node is not meant to be started as PID 1
RUN apk update && apk add --no-cache dumb-init

#   Setting up the working directory in the container itself
WORKDIR /app

#   Copying the package*.json files to the previously configured working directory
COPY package*.json ./

#   Executing the package.json file with npm 
RUN npm install


#   MULTI STAGE BUILD

FROM node:alpine

#   Setting the environment variable NODE_ENV to production, to increase performance and security
ENV NODE_ENV=production

WORKDIR /app

#   Create a non-root user to restrict permissions to the working directory
RUN adduser -D awsec-node && chown -R awsec-node /app

#   UID set to a non-root user to avoid unnecessary privileges, the default user 'node' can be used alternatively
USER awsec-node

#   Copying all freshly files to the working directory
COPY --chown=awsec-node --from=base package*.json ./
COPY --chown=awsec-node --from=base /usr/bin/dumb-init /usr/bin/dumb-init
COPY --chown=awsec-node . .
#   Exposing a port in the container to access the node application

RUN npm install --production

EXPOSE 3333

#   Starting the node server by the 'exec form' with node directly, not with 'npm start'
#   In that way the Node process does not miss any possible SIG-Events which could be sent - it can occur that npm does not forward every SIG-Event to the node process  
#   reference: https://snyk.io/de/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/

#   A healthcheck is permformed to check if the container is still running
#   TODO: gucken, warum localhost nicht klappt und container unhealthy, obwohl läuft - am curl aufruf liegts nicht
HEALTHCHECK --interval=1m --timeout=5s \
  CMD curl -f http://127.0.0.1:3333 || exit 1
  

CMD [ "dumb-init", "node", "app.js" ]