FROM node:12-alpine

WORKDIR /app

# Устанавливаем системные утилиты (crond, bash, tzdata)
RUN apk add --no-cache bash curl tzdata \
 && cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
 && echo "Europe/Moscow" > /etc/timezone

# Копируем только необходимые файлы для сборки
COPY package*.json ./

RUN npm ci

COPY gulpfile.js babel.config.js ./
COPY crontab.txt ./crontab.txt
COPY rebuild-ps-map.sh ./rebuild-ps-map.sh
COPY scripts ./scripts
COPY app ./app

# Назначаем права
RUN chmod +x /app/rebuild-ps-map.sh && crontab /app/crontab.txt

# Сборка
RUN npm run build

# Запускаем cron в foreground и логируем в stdout
CMD ["crond", "-f", "-L", "/var/log/cron.log"]