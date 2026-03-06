# base image
FROM node:18-alpine

# app directory
WORKDIR /app

# copy dependency files
COPY package*.json ./

# install dependencies
RUN npm install

# copy app code
COPY . .

# expose app port
EXPOSE 3000

# start app
CMD ["npm", "start"]