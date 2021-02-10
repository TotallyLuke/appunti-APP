# 7: Esempi svolti 2

---

## Esempi


Completiamo un ulteriore esempio che ci servirà negli argomenti successivi.

---

## TicTacToe


Il gioco del TicTacToe è il classico gioco a due giocatori in cui bisogna mettere in fila tre simboli uguali.

![TicTacToe](./imgs/l06/tictactoe.png)


Per gli esercizi successivi, abbiamo bisogno di una oggetto che gestisca una partita. Necessitiamo di:
* stato attuale del gioco
* elenco delle mosse disponibili
* calcolo del prossimo stato del gioco data una mossa


Per "stato attuale del gioco" si intende:
* una stringa che rappresenta il piano di gioco
* se il gioco è in corso o terminato (e come)
* il giocatore di turno


Per "elenco delle mosse disponibili" si intende:
* un elenco da cui un giocatore (umano o non) può scegliere esclusivamente le mosse valide per proseguire il gioco


Per "calcolo del prossimo stato del gioco" si intende:
* fornita una mossa, produrre un nuovo oggetto contenente lo stato del gioco dopo l'applicazione della mossa

Per esigenze legate all'uso concorrente, quest'oggetto dev'essere assolutamente slegato da quello originale.

---

## Consegna degli esercizi


Come test del metodo di consegna degli esercizi, verifichiamo il comportamento dei componenti coinvolti.


## Prerequisiti

* java/gradle
* hg


```bash
PS app2020-pub> .\gradlew -version

------------------------------------------------------------
Gradle 6.6.1
------------------------------------------------------------

Build time: 2020-08-25 16:29:12 UTC
Revision: f2d1fb54a951d8b11d25748e4711bec8d128d7e3

Kotlin: 1.3.72
Groovy: 2.5.12
Ant: Apache Ant(TM) version 1.10.8 compiled on May 10 2020
JVM: 15 (AdoptOpenJDK 15+36)
OS: Windows 10 10.0 amd64
```


```bash
PS app2020-pub> hg --version
Mercurial SCM Distribuito (versione 5.5.2)
(see https://mercurial-scm.org for more information)

Copyright (C) 2005-2020 Matt Mackall and others
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```


```bash
PS app2020-pub> hg summary
genitore: 8:0a94ff0a0c4b tip
Lezione 07
branch: default
commit: (pulito)
update: (aggiornato)
```


## Creazione del branch


```bash
PS app2020-pub> hg branch 342258IF
marcata directory di lavoro come branch 342258IF
(branches are permanent and global, did you want a bookmark?)
PS app2020-pub> .\gradlew -version > version.txt
PS app2020-pub> hg --version >> version.txt
PS app2020-pub> hg add version.txt
PS app2020-pub> hg commit -m "Versioni usate"
```


```bash
PS app2020-pub> .\gradlew test

49 tests completed, 35 failed

> Task :test FAILED

FAILURE: Build failed with an exception.

BUILD FAILED in 5s
3 actionable tasks: 3 executed
```


```bash
PS app2020-pub> hg add src\main\java\it\
  unipd\app2020\bowling\Oggetto.java
PS app2020-pub> .\gradlew test spotlessApply

BUILD SUCCESSFUL in 6s
7 actionable tasks: 4 executed, 3 up-to-date

PS app2020-pub> hg commit -m "Soluzione test"
```


## Invio del bundle


```bash
PS app2020-pub> hg bundle -b 342258IF 342258IF.hg
PS app2020-pub> dir 342258IF.hg
-a---- 22/10/2020 09:19 4589 342258IF.hg
```


![Carica in drive](./imgs/l07/carico.png)


![Condividi](./imgs/l07/condividi.png)


![Destinatario](./imgs/l07/destinatario.png)

---

## Link Interessanti


* Programming Love (https://programming.love/)
* JLove conference (https://jlove.konfy.care/)

