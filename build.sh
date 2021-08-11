#!/bin/sh
cat doc_info.md lesson01.md lesson02.md lesson03.md lesson04.md lesson05.md lesson06.md lesson07.md lesson08.md lesson09.md lesson10.md lesson11.md lesson12.md lesson13.md lesson14.md lesson15.md lesson16.md lesson17.md lesson18.md lesson19.md lesson20.md lesson21.md lesson22.md lesson23.md lesson24.md > tmp_book.md 
sed -i 's/svg/png/g' tmp_book.md
# pandoc "tmp_book.md" -o "tmp_book.tex" --from markdown --template "https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex" --listings
pandoc "tmp_book.md" -o "tmp_book.tex" --from markdown --template "https://raw.githubusercontent.com/oehrlis/pandoc_template/master/templates/trivadis.tex" --listings
latexmk -pdf -f -interaction=nonstopmode tmp_book.tex -jobname="Appunti-APP"
#clean house
rm -f *.aux *.ext *.idx *.ilg *.ind *.log *.lot *.lof *.tmp *.out *.glo *.gls *.fls *.fdb* *.toc *.xtr
rm -f tmp_book.md tmp_book.tex
