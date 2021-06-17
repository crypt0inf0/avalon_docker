FROM node:12
LABEL "project.home"="https://github.com/dtube/avalon"
RUN git clone https://github.com/techcoderx/avalon.git --branch hf4-testnet --single-branch
WORKDIR /avalon
RUN npm install

EXPOSE 6001
EXPOSE 3001
CMD ["npm", "start"]
