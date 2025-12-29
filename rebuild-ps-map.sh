#!/bin/bash
set -e

# rebuild-ps-map.sh — пересборка ps-map без переустановки зависимостей
# Оптимизировано для работы в cron

# Абсолютные пути
APP_DIR="/app"
LOG_FILE="/var/log/cron/ps-map.log"

# Добавляем путь к бинарям Node и npm
export PATH=$PATH:/app/node_modules/.bin

# Переходим в рабочую директорию
if [ ! -d "$APP_DIR" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Directory $APP_DIR not found!" >> "$LOG_FILE"
  exit 1
fi
cd "$APP_DIR"

# Проверяем наличие package.json
if [ ! -f "$APP_DIR/package.json" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] package.json not found in $APP_DIR" >> "$LOG_FILE"
  exit 1
fi

# Проверяем наличие node_modules
if [ ! -d "$APP_DIR/node_modules" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] node_modules not found! Skipping rebuild to avoid errors." >> "$LOG_FILE"
  exit 1
fi

# Начало сборки
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Starting site rebuild..." >> "$LOG_FILE"

# Сборка проекта (gulp)
npm run build >> "$LOG_FILE" 2>&1

# Проверяем результат
if [ -d "$APP_DIR/dist" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Build completed successfully. Output: $APP_DIR/dist" >> "$LOG_FILE"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] dist directory not found after build!" >> "$LOG_FILE"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Rebuild finished." >> "$LOG_FILE"