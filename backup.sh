#!/bin/sh

DUMP_FILE_NAME="backupOn$(date +%Y-%m-%d-%H-%M).dump"
echo "Creating dump: $DUMP_FILE_NAME"

cd pg_backup || exit

pg_dump -C -w --format=c --blobs > "$DUMP_FILE_NAME"

if [ $? -ne 0 ]; then
  rm "$DUMP_FILE_NAME"
  echo "Back up not created, check db connection settings"
  exit 1
fi

response=$(az storage blob upload \
    --account-name "$AZ_STORAGE_ACCOUNT" \
    --container-name "$AZ_CONTAINER" \
    --name "$AZ_BLOB" \
    --file "$DUMP_FILE_NAME" \
    --sas-token "$AZ_SAS_TOKEN" \
    --auth-mode key)

echo "Server Antwort: $response"

if [ "$response" = "Upload Successful" ]; then
    echo "Backup war erfolgreich."
else
    echo "Backup ist fehlgeschlagen."
fi

rm "$DUMP_FILE_NAME"
exit 0