# Car Rental App

## Build multi platform image

- `podman build --platform linux/amd64,linux/arm64 --manifest django-test .`
- `podman tag localhost/django-test gaborka98/django-test:latest`
- `podman manifest rm localhost/django-test`
- `podman manifest push --all gaborka98/django-test:latest docker://docker.io/gaborka98/django-test:latest`