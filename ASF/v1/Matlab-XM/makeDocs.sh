#!/usr/bin/tcsh
find . -name '*.m' -exec awk -f makeDocs.awk \{\} \; >! XMdocs2.txt
