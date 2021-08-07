#!/bin/sh
cat doc_info.md lesson01.md lesson02.md lesson03.md lesson04.md lesson05.md lesson06.md lesson07.md lesson08.md lesson09.md lesson10.md lesson11.md lesson12.md lesson13.md lesson14.md lesson15.md lesson16.md lesson17.md lesson18.md lesson19.md lesson20.md lesson21.md lesson22.md lesson23.md lesson24.md > book.md 
pandoc "book.md" -o "appunti-APP.tex" --from markdown --template "../eisvogel.tex" --listings
latexmk -pdf -f -interaction=nonstopmode appunti-APP.tex
