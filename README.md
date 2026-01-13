# prpo-app


## Skupina
- Ime skupine: **FRIDOM**
- 4. skupina
- Člani: **Monika Simičak**, **Adrian Sebastian Šiška**
- GitHub povezava: [github.com/orgs/prpo-skupina4](https://github.com/orgs/prpo-skupina4)
- Url: [fritime.computers.si](https://fritime.computers.si)

## Projekt
- Ime: **FRITIME**
- Opis: Prilagodljiv urnik FRI
   Aplikacija, ki samodejno prebere podatke o predavanjih in vajah z urnikov (Preko protokola iCal). 
   Na podlagi uporabnikovih želja in filtrov sestavi optimalen urnik.
   Uporabnik lahko nastavi svoje preference (npr. zgodnji ali pozni začetek, prosti dnevi, skupina prijateljev), aplikacija pa poišče najboljšo kombinacijo terminov.
   Možno je tudi ustvarjanje skupnih urnikov za več uporabnikov in dodajanje časa za skupno kosilo.

- Ogrodja in razvojno okolje:
    - **Pytest**
    - Azure
    - FastAPI
    - GitHub
    - Kubernetes
    - Python
    - **Python venv**
    - SQLAlchemy
    - SQLite
    - VSCode
    - ~~Zig~~


### Seznam mikrostoritev
- Event view

    Vrne podatke o urniku za prikaz.

- Optimizator

    Optimizira urnik glede na želje, filtre.

- Boolean

    Vrne podatke skupnega urnika za več oseb.

- Kosilo

    Doda kosilo na urnik, ki si ga deli več ljudi.

- User managment

    Poskribi za avtentiakcijo in avtorizacijo uporabnikov.

- iCal

    Prevzame podatke o urniku iz iCal povezave. (npr. `urnik.fri.uni-lj.si`)

### Primeri uporabe

- Uporabnik se prijavi v aplikacijo, prikaže mu njegov urnik.
- Uporabnik želi drugačen urnik, npr. noče imeti v petek obveznosti, uporabi filter in aplikacija mu generira nov urnik.
- Uporabnik želi najti uro, ko ima z drugim uporabnikom hkrati pavzo. Klikne na gumb "kombiniraj urnik" in izbere enega ali več uporabnikov.
Aplikacija mu prikaže kombiniran urnik.
- Uporabnik želi vključiti kosilo v urnik, klikne gumb "dodaj kosilo", izbere dan v tednu ter prijatelje s katerimi bi kosil.
  Nato se mu prikaže dokodek, ki predstavlja kosilo, katerega se lahko vsi izbrani udeležijo.

### Seznam opravljenih/vključenih osnovnih in dodatnih projektnih zahtev
- Repozitorij

    Repozitorije sva naredila na Github-u v kotekstu organizacije.
    Razvoj sicer zaenkrat poteka na main veji, vendar deployment gleda tag-e in za majhne projekte ni problematično ustvariti feature vej.
    Vsak repozitorij vsebuje README.
    
- Razvojno okolje

    Razvojno okodje je sestavjeno iz VSCode-a ali emacs-a, python venv-a in Dockerfile.
    Začetne procedure so dokumentirane v README datotekah.
    Razvojno okolje je postavljeno tako, da ni intruzivno in lahko drugi razvjalci uporabljajo poplnoma svoje.
    (brez .vscode commitov)

- Mikrostoritve

    Naredila sva več mikrostoritveno arhitekturo, ki med sabo komunicirajo po http protokolu.

- REST

    Implementirala sva REST-ful API za vsako mikrostoritev.
    Paginacija in filtriranje sta implementirana kjer je to smiselno (User-auth-manager). (Glej APIdokumentacijo)

- Dokumentacija API

    Z uporabo paketa FastAPI je generacija API dokumentacije avtomatska in dostopna na `/docs` ter `/redoc`.
    Na `/openapi.json` pa je na voljo openAPI specifikacija.

- Vsebniki

    Za vsako storitev sva napisala Dockerfile.
    Github Actions pa jih objavi na dockerhub-u.

- Kubernetes

    Z kubernetes sva imela največ problemov, saj na nekaterih uni-lj naslovih ne deluje.
    Kljub temu sva deploy-ala najino storitev na Azure Kubernetes servic-u.

- Cevovod CI/CD

    Za vsako mikrostoritev uporabljava Github Action-e, da izvedeva teste ter objaviva Dockerfile na Dockerhub.

- Namestitev v oblak

    Azure Kubernetes, ki ga uporabljava je že v oblaku.

- Poslovna logika

    Vsaka mikrostoritev implementira in skrbi za svojo poslovno logiko.

- Dokumentacija

    Za dokumentacijo sva uporabila github Wiki. (repozitorij Prpo-app)
    Format v katerem je dokumentacija spisana je iz družine Markown-ov.

- Zunanji API

    Za zunanji API uporabljava (https://openweathermap.org/)[openweathermap.org].
    Za API token managment se zanašava na Kubernetes.

- Podatkovna baza

    Za podatkovno bazo uporabljava Azure SQL Database.
    Podakovni bazi sta ločeni po meji mikrostoritev.
    Prva hrani osnovne podatke o uporabnikih (mail, vpisna št., geslo)
    Druga pa dodatne podatke, ki jih uporabnik poda (preference o urniški postavitvi, itd.)
    (Glej arhitekturo mikrostoritev.)

- ORM

    Za ORM uporabljava SQLAlchemy in implimentirava CRUD operacije.
    
- Preverjanje zdravja

    Vsaka mikrostoritev implementira "/health" API endpoint.
    Za preverjanje zdravja se zanašava na Kubernetes `livenessProbe`.

- Skaliranje

    Za skaliranje uporabljava Kubernetes `HorizontalPodAutoscaler` ter azure approuter.

- Grafični vmesnik

    Za grafični vmesnik sva implementirala progresivno spletno stran v React-u.
    Z mikrostoritvami komunicira preko REST API-jev.

### Shema arhitekture
![slika sheme diagrama arhitekture](slika_arhitekture.svg){ width=50% }
