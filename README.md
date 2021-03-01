# Resume

Uses [JSON Resume](https://jsonresume.org/) to generate my resume, using `./resume.json`.

## Usage

```bash
make build # does everything, including running nginx on port 12201
```

If you don't want nginx, just run:

```bash
make reset-theme
make build-resume
```

To conserve bandwidth, don't run `make reset-theme` every time. It's only necessary the first time.

The output will be under `docs/index.html`.

## TODO

* Dockerize
