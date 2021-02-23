# Resume (Webpage version)

Generates the webpage only. PDF doesn't seem to be able to capture the webfonts in time for render.

TODO: Port over the third-party replacement code from my other resume repo.

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

The output will be under `dist/resume.html`. This file and the `pictures` directory should be served up by your HTML renderer.
