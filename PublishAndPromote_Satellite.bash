#!/usr/bin/env bash

# --------------------------------------------------------------
# Date:
# April 02, 2021
# --------------------------------------------------------------

# Make sure this hasn't been published / promoted yet
FILE=$(find /tmp -type f -iname "*dev-qa-promoted*")
if [[ -n "$FILE" ]]
    then
        TIME=$(echo "$FILE" | awk -F '.' '{print $(NF)}')
        echo -en "\n\nWe already published the composite content views on $(date +"%A %B %d, %Y %H:%M:%S %Z" -d @${TIME})\n\n\tAre you sure you want to continue? [y/n]\n\t--> "
        read -r -n1 GONOGO
        case "$GONOGO" in
            y|Y)
                echo -en "\n\nMoving on ... \n\n"
                ;;
            n|N)
                echo -en "\n\nGoodbye!\n\n"
                exit 1
                ;;
        esac
fi

# Gather the next month
NEXT_MONTH=$(date +"%B" -d "next month")

# Publish non-composite content-views
DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
echo -en "\nPublishing new versions of non-composite content views ... \n"
echo -en "\n\n$DATE:\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
echo -en "Auto publish for $NEXT_MONTH monthly patching cycle\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
while IFS= read -r LINE
    do
        DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
        CV_ID=$(echo "$LINE" | awk -F ',' '{print $1}')
        CV_NAME=$(echo "$LINE" | awk -F ',' '{print $2}')
        {
            echo -en "Publishing \"$CV_NAME ($CV_ID)\" ... \n"
            hammer content-view publish --description="Auto publish for \"$CV_NAME\" $NEXT_MONTH monthly patching cycle ($DATE)" --id="$CV_ID"
            echo -en "\n"
        } >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
    done < <(hammer content-view list --organization-id="1" --noncomposite="1" --fields="Content View ID,Name" | grep -Eiv 'Default Organization View' | grep -Ei '^[0-9]{1,}' | sed -r 's/\s+//g' | sed -r 's/\|/,/g')

# Publish composite content-views
DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
echo -en "\nPublishing new versions of composite content views ... \n"
echo -en "\n\n$DATE:\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
echo -en "Auto publish for $NEXT_MONTH monthly patching cycle\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
while IFS= read -r LINE
    do
        DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
        CV_ID=$(echo "$LINE" | awk -F ',' '{print $1}')
        CV_NAME=$(echo "$LINE" | awk -F ',' '{print $2}')
        {
            echo -en "Publishing \"$CV_NAME ($CV_ID)\" ... \n"
            hammer content-view publish --description="Auto publish for \"$CV_NAME\" $NEXT_MONTH monthly patching cycle ($DATE)" --id="$CV_ID"
            echo -en "\n"
        } >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
    done < <(hammer content-view list --organization-id="1" --composite="1" --fields="Content View ID,Name" | grep -Eiv 'Default Organization View' | grep -Ei '^[0-9]{1,}' | sed -r 's/\s+//g' | sed -r 's/\|/,/g')

DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
COMPOSITE_VIEWS=('21,6Server_DEFAULT_CV' '22,7Server_DEFAULT_CV' '23,8Server_DEFAULT_CV')
echo -en "\nPromoting composite content-views to DEV/QA ... \n"
echo -en "\n\n$DATE:\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
echo -en "Auto promotion for $NEXT_MONTH monthly patching cycle\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
for ITEM in "${COMPOSITE_VIEWS[@]}"
    do
        DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
        CV_ID=$(echo "$ITEM" | awk -F ',' '{print $1}')
        CV_NAME=$(echo "$ITEM" | awk -F ',' '{print $2}')
        {
        echo -en "Promoting $CV_NAME to DEV ... \n"
        VERSION_ID=$(hammer content-view version list --content-view-id="$CV_ID" --fields id --order="version DESC" | grep -Ei '[0-9]{1,3}' | head -1)
        # Dev Environment
        hammer content-view version promote --description="Auto promote for \"$CV_NAME\" $NEXT_MONTH monthly patching cycle ($DATE)" --content-view-id="$CV_ID" --id="$VERSION_ID" --to-lifecycle-environment-id="2"
        echo -en "Promoting $CV_NAME to QA ... \n"
        # QA Environment
        hammer content-view version promote --description="Auto promote for \"$CV_NAME\" $NEXT_MONTH monthly patching cycle ($DATE)" --content-view-id="$CV_ID" --id="$VERSION_ID" --to-lifecycle-environment-id="3"
        } >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
    done
# Set a hidden file so we know we have promoted this
touch /tmp/.dev-qa-promoted."$(date +'%s')"

# Promoting Satellite content-view to CORP/PROD
DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
COMPOSITE_VIEWS=('31,Satellite_CV')
echo -en "\nPromoting Satellite content-view to CORP/PROD ... \n"
echo -en "\n\n$DATE:\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
echo -en "Auto promotion for $NEXT_MONTH monthly patching cycle\n" >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
for ITEM in "${COMPOSITE_VIEWS[@]}"
    do
        DATE=$(date +"%A %B %d, %Y %H:%M:%S %Z")
        CV_ID=$(echo "$ITEM" | awk -F ',' '{print $1}')
        CV_NAME=$(echo "$ITEM" | awk -F ',' '{print $2}')
        VERSION_ID=$(hammer content-view version list --content-view-id="$CV_ID" --fields id --order="version DESC" | grep -Ei '[0-9]{1,3}' | head -1)
        {
        # CORP Environment
        echo -en "Promoting $CV_NAME to CORP ... \n"
        hammer content-view version promote --description="Auto promote for \"$CV_NAME\" $NEXT_MONTH monthly patching cycle ($DATE)" --content-view-id="$CV_ID" --id="$VERSION_ID" --to-lifecycle-environment-id="5"
        # PROD Environment
        echo -en "Promoting $CV_NAME to PROD ... \n"
        hammer content-view version promote --description="Auto promote for \"$CV_NAME\" $NEXT_MONTH monthly patching cycle ($DATE)" --content-view-id="$CV_ID" --id="$VERSION_ID" --to-lifecycle-environment-id="8"
        } >> /root/logs/PublishAndPromote_"${NEXT_MONTH}".log
    done
