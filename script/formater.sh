#!/usr/bin/bash
# git diff --name-only --diff-filter=ACM

for i in $(git diff --name-only --diff-filter=ACM|grep .vala$);
do
    uncrustify -l VALA  -c uncrustify.cfg --replace --no-backup $i;
done