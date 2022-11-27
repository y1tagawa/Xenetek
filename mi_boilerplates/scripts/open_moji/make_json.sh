#!/bin/sh

# Get from https://commons.wikimedia.org/wiki/Emoji/Table and generate index to code, name, keywords table.

# Do it once per updated.
#wget https://commons.wikimedia.org/wiki/Emoji/Table

# Genetate table.
echo '{' >table.json
grep -e '^<td><code>\|^<td style="text-align: initial">\|^<th>[0-9]' Table | \
sed -e 's/<th>\([0-9]*\)/"\1":{/g' | \
sed -e 's/<\/code> <br \/> <code>/-/g' -e 's/<\/code>/",/g' -e 's/<td><code>/"code":"/g' | \
sed -e 's/<br \/><small>/","keywords": "/g' -e 's/<\/small>/"},/g' -e 's/<td style="text-align: initial">/"name":"/g' | \
sed ':a; N; $!ba; s/\n//g' | \
sed -e 's/},$/}/g' | \
sed -e 's/},/},\n/g' >>table.json
echo '}' >>table.json
