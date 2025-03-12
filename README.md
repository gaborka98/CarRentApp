# Car Rental App

## TODOs

### github actions:

#### buid: (on PR)

- [x] unit tests
- [ ] sonarqube
- [x] pycodestyle
- [x] bandit
- [x] docker build
- [x] grype

nice ot have a git diff filter:
only run checkov if IAC folder changed

#### tf pipeline deploy infra:

- [x] container apps for app
- [x] keyvault for admin pw
- [x] postgre for db

---

- [x] tf plan
- [ ] checkov ????
- [ ] sonarqube ????
- [x] tf apply

#### Main branch pipeline

- [x] check merge message contains version
- [x] build docker image
- [x] push docker image
- [ ] deploy app to container apps