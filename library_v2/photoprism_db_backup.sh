#!/bin/bash

BACKUP_DIR="/storage/mariadb_dumps"
LOG_FILE="/var/log/mariadb_backup.log"

# Проверка места
if [ $(df --output=pcent /storage | tail -1 | tr -d '%') -gt 90 ]; then
    echo "$(date) - ERROR: Not enough disk space" >> $LOG_FILE
    exit 1
fi

# Дамп и сжатие
docker exec mariadb mysqldump -u root -p"${DB_ROOT_PASSWORD}" --single-transaction photoprism | \
gzip > "$BACKUP_DIR/photoprism_$(date +\%Y\%m\%d).sql.gz" 2>> $LOG_FILE

# Удаление старых бэкапов (>30 дней)
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +30 -delete >> $LOG_FILE
