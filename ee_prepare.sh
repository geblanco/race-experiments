#!/bin/bash

# requires xml2json
if [[ "$#" -lt 1 ]]; then
  echo "Usage ee_prepare <ee_dataset_folder>"
  exit 0
fi

# convert all xml files to json, then json to RACE like format
for xml_file in $(find $1 -iname "*.xml"); do
  xml_file=$(basename $xml_file)
  json_file=${xml_file%.*}.json
  echo "xml2json $xml_file /tmp/$json_file"
  cat $1/$xml_file | xml2json > /tmp/$json_file
  echo "python /tmp/$json_file $1/$json_file"
  python3 ee_processor.py -i /tmp/$json_file > $1/$json_file
done

