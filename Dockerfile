
FROM node:12
LABEL "project.home"="https://github.com/dtube/avalon"
RUN git clone git://github.com/dtube/avalon
WORKDIR /avalon
RUN npm install

EXPOSE 6001
EXPOSE 3001
CMD ["npm", "start"]