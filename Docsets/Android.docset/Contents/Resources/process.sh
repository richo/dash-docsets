#!/bin/bash

cd $(dirname $0)

ref_dir="Documents/docs/reference"
package_html="$ref_dir/classes.html"
class_html="$ref_dir/classes.html"

xml="Tokens.xml"
file_packages=tmp.packages
file_classes=tmp.classes

####
echo "packages: processing..."
cat "$package_html" | grep '<a href="../reference/' | grep '</a></li>' \
    | sed -e 's/^  <a href="\.\./docs/' | sed -e 's/<\/a><\/li>$//' | sed -e 's/">/ /' \
    > $file_packages
echo "packages: done."

###
echo "classes: processing..."
cat "$class_html" | grep '            <td class="jd-linkcol"><a href="../reference/' | grep '</a></td>' \
    | sed -e 's/^            <td class="jd-linkcol"><a href="\.\./docs/' | sed -e 's/<\/a><\/td>$//' | sed -e 's/">/ /' \
    > $file_classes
echo "classes: done."

###
echo "Tokens.xml: merging..."
cat > $xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Tokens version="1.0">
EOF
cat "$file_packages" | awk '{print "<File path=\""$1"\"><Token><TokenIdentifier>//apple_ref/java/cl/"$2"</TokenIdentifier></Token></File>"}' \
    >> $xml
cat "$file_classes" | awk '{print "<File path=\""$1"\"><Token><TokenIdentifier>//apple_ref/java/cl/"$2"</TokenIdentifier></Token></File>"}' \
    >> $xml
echo "</Tokens>" >> $xml
echo "Tokens.xml: done."