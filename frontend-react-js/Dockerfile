FROM node:latest

ENV PORT=3000 \ 
    REACT_APP_BACKEND_URL=http://localhost:4567

COPY . /frontend-react-js

WORKDIR /frontend-react-js

RUN npm install 

EXPOSE ${PORT}

CMD ["npm", "start"]