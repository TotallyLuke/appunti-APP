# appunti-APP
Appunti del corso "Altri Paradigmi di Programmazione" tenuto da Michele Mauro nell'anno accademico 2020-21. Principalemente ottenuti estraendo il markdown dai sorgenti reveal.js del professore, aggiungendo testo (le cose più superflue) e togliendone pure un poco (le parti più importanti)

Invito a preferire le fonti ufficiali che il professore vi fornisce gentilmente, sebbene sia ben noto che dispense in prosa >> slides (ma queste sono slides in prosa, quindi il principio non si applica).

Sicuramente gli appunti contengono errori. Qualcuno contribuisca negli anni futuri, grazie.

## Genarazione del PDF
Requisiti:

- *pandoc*
- *MiKTeX* o *TexLive* installati in locale

Aprire un terminale nella directory `Appunti-APP` ed eseguire il comando `./build.sh`


### Conversione svg in png

Nella cartella `imgs/` dovrebbero essere caricate entrambe le versioni per le immagini caricate dal professore come svg. Qualora la build desse problemi di file png non trovato è probabile che sia caricata solo la versione png. Lanciare dunque 'svg\_to\_png.sh'.
Questo richiede avere installato *inkscape* in locale. Se la repo è mantenuta come dio comanda questo paragrafo dovrebbe essere inutile per i non manutentori/caricatori.


