# Cloner le dépôt Git
FROM ubuntu:18.04 as files
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install git -y
RUN git clone https://github.com/omarvm001/Devops-projet-02-GITLAB.git /project


# Copier le code source dans une nouvelle image légère
FROM nginx:stable-alpine3.17-slim
LABEL org.opencontainers.image.authors="Omar Bouchenak omar.vm.001@gmail.com"
COPY --from=files /project /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'

