# 6: Esempi svolti

---

## Esempi


Dopo aver visto rapidamente le principali caratteristiche del linguaggio Java, proviamo a risolvere alcuni semplici problemi per verificare direttamente che aspetto ha e come si comporta un programma.


## TDD


Per avere un comodo ambiente di esecuzione, e per rendere più interessante l'esercizio, useremo la libreria JUnit per scrivere dei test e verificare in questo modo il comportamento del codice.


Le fasi del TDD sono:

- Pensa al problema e a come scrivere il test
- Scrivi un test
- Osservalo fallire
- Scrivi il minimo codice necessario a farlo passare
- Ristruttura
- Ripeti

Cfr. http://wiki.c2.com/?TestDrivenDevelopment

---

### Fibonacci


La serie di Fibonacci è una sequenza numerica definita ricorsivamente:

- fib(0) = 0
- fib(1) = 1
- fib(n) = fib(n-2) + fib(n-1)

---

### Kata

Nelle arti marziali giapponesi, _kata_ (forma) indica la forma pura ed essenziale di una singola mossa o colpo, studiata singolarmente allo scopo di ricercarne l'esecuzione perfetta.

Esercitarsi nei _kata_ significa quindi ripetere deliberatamente lo stesso movimento per assimilarlo e per analizzarne l'esecuzione.


Ispirandosi a questo concetto, Dave Thomas nel libro "The Pragmatic Programmer" descrive il kata nella programmazione come l'esercizio deliberato di risolvere un problema più volte ponendo attenzione sul processo che ci porta alla soluzione piuttosto che sul risultato.

La ripetizione, oltre a permetterci di provare strade diverse, ci consente di analizzare come il procedimento cambia nel tempo. Dopo poche ripetizioni, il problema in sè diventa irrilevante, ed un mero pretesto per analizzare la pratica con cui viene risolto.


### Bowling

Uno dei primi Kata ad essere codificati è il problema del calcolo del punteggio del Bowling.

Si presta particolarmente a questo tipo di esercizio in quanto è un problema semplice, ma presenta delle irregolarità che rendono impegnativo individuare una soluzione elegante e semplice.


Una partita di bowling si divide in 10 Frame in cui un giocatore deve abbattere 10 birilli. Nei primi 9 frame il giocatore ha due tiri.

![Bowling-1](./imgs/l06/bowling1.png)


Se in un frame il giocatore abbatte meno di 10 birilli, ottiene come punteggio il numero di birilli abbattuti. Un tiro a vuoto si segna con il segno "-".

![Bowling-2](./imgs/l06/bowling2.png)


Se abbatte i 10 birilli in due tiri, ottiene uno _spare_, e conta come bonus il numero di birilli abbattuti con il tiro seguente. Si segna con il carattere '/'.

![Bowling-3](./imgs/l06/bowling3.png)

Il frame 3 vale 18: 10+8 del primo tiro del frame 4.


Se abbatte i 10 birilli in un solo tiro, ottiene uno _strike_ e conta come bonus il numero di birilli abbattuti nei due tiri seguenti. Si segna con una sola 'X' nel frame.

![Bowling-4](./imgs/l06/bowling4.png)

Il frame 5 vale 24: 10+10+4. Il frame 6 vale 19: 10+4+5.


Nel decimo frame, se ottiene uno strike o uno spare nei primi due tiri, ha un terzo tiro con cui calcolare il bonus per il punto segnato.

![Bowling-5](./imgs/l06/bowling5.png)

Il frame 10 vale 16: 10+6


Lo scopo del Kata è produrre una classe `BowlingGame` che produca, con un metodo `score()` il punteggio della partita.

---

## Link Interessanti

**7 minutes 26 seconds and the Fundamental Theorem of Agile Software Development**
https://www.youtube.com/watch?v=WSes_PexXcA

