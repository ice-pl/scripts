#!/usr/bin/env bash
mkdir org

for FILE in ./*.pdf; do
  # pdfcrop "${FILE}"
  # pdfcrop --margins '-10 -10 -10 -300' "${FILE}" "${FILE}_cropped"
  # pdf-crop-margins -v -s -u "${FILE}"
  pdf-book-create.sh "${FILE}"
  mv "${FILE}" org/"${FILE}"
done
