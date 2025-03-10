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

- [ ] container apps for app
- [ ] keyvault for admin pw
- [ ] postgre for db

---

- [ ] tf plan
- [ ] checkov ????
- [ ] sonarqube ????
- [ ] tf apply

#### Main branch pipeline

- [ ] check merge message contains version
- [ ] build docker image
- [ ] push docker image
- [ ] deploy app to container apps