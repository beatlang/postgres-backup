#!/bin/sh
WEEK_DAYS=7
MONTH_DAYS=28
DAY_OF_WEEK=$(date +%u)
DAY_OF_MONTH=$(date +%d)

if [ "$DAY_OF_MONTH" -eq "$MONTH_DAYS" ]; then
  DUMP_FILE_NAME="monthly-backup-$(date +%Y-%m-%d-%H-%M).dump"
elif [ "$DAY_OF_WEEK" -eq "$WEEK_DAYS" ]; then
  DUMP_FILE_NAME="weekly-backup-$(date +%Y-%m-%d-%H-%M).dump"
else
  DUMP_FILE_NAME="daily-backup-$(date +%Y-%m-%d-%H-%M).dump"
fi

echo "Creating dump: $DUMP_FILE_NAME"

mkdir -p "$HOME"/pg_backup && cd $_ || exit
pg_dumpall -c >"$DUMP_FILE_NAME"

if [ $? -ne 0 ]; then
  rm "$DUMP_FILE_NAME"
  echo "Back up not created, check db connection settings"
  exit 1
fi

az storage blob upload \
  --account-name "$AZ_STORAGE_ACCOUNT" \
  --container-name "$AZ_CONTAINER" \
  --account-key "$AZ_ACCOUNT_KEY" \
  --name "$DUMP_FILE_NAME" \
  --file "$DUMP_FILE_NAME" \
  --auth-mode key

if [ $? -ne 0 ]; then
  echo "Backup ist fehlgeschlagen."
  exit 1
fi

echo "Backup war erfolgreich."
exit 0
