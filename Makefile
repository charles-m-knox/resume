

# gets used like .pdf or .all
OUTPUT_FILENAME=index

# can be all instead
OUTPUT_FILE_TYPE=html

# must be stored in the "docs" directory
PICTURE_FILENAME=TechLife23_centered-position-14x2_full-bg-shadow.png

THEME_DIR=jsonresume-theme-elegant
DIST_DIR=docs
RESUME_JSON=resume.json
PWD=$(shell pwd)
UNAME=$(shell uname -s)

CONTAINER_NAME=resume-nginx

install-prerequisites:
	npm install -g hackmyresume grunt
ifeq ($(UNAME), Darwin)
	brew install --cask wkhtmltopdf
else ifeq ($(UNAME), Linux)
	sudo apt install -y wkhtmltopdf
else
	echo "Unrecognized platform. Please inspect the Makefile to alter this file manually."
	exit 1
endif

reset-theme:
	-rm -rf $(THEME_DIR)
	git clone https://github.com/mudassir0909/jsonresume-theme-elegant $(THEME_DIR)
	cd $(THEME_DIR); npm install
	# sed is different on Mac than it is on Linux. The -i flag is not needed
	# on Mac.
	# https://stackoverflow.com/a/3466183/3798673
ifeq ($(UNAME), Darwin)
	sed -i "_tmp" 's|//unpkg.com/jsonresume-theme-elegant@@{theme-version}/assets/icomoon/fonts|https://unpkg.com/jsonresume-theme-elegant@@{theme-version}/assets/icomoon/fonts|g' ./$(THEME_DIR)/assets/less/icon.less
	-rm "./$(THEME_DIR)/assets/less/icon.less_tmp"
else ifeq ($(UNAME), Linux)
	sed -i 's|//unpkg.com/jsonresume-theme-elegant@@{theme-version}/assets/icomoon/fonts|https://unpkg.com/jsonresume-theme-elegant@@{theme-version}/assets/icomoon/fonts|g' ./$(THEME_DIR)/assets/less/icon.less
else
	echo "Unrecognized platform. Please inspect the Makefile to alter this file manually."
	exit 1
endif
	cd $(THEME_DIR); grunt build

build-resume:
	hackmyresume -d build "$(RESUME_JSON)" TO "$(DIST_DIR)/$(OUTPUT_FILENAME).$(OUTPUT_FILE_TYPE)" -t "./$(THEME_DIR)/"

# note: serve-resume requires that the OUTPUT_FILENAME is either "html" or "all"
# (without quotes)
serve-resume:
	docker rm -f "${CONTAINER_NAME}" || true
	docker run \
		-it \
		-d \
		--name "${CONTAINER_NAME}" \
		--restart unless-stopped \
		-v $(PWD)/$(DIST_DIR)/$(OUTPUT_FILENAME).html:/usr/share/nginx/html/index.html \
		-v $(PWD)/$(DIST_DIR)/$(PICTURE_FILENAME):/usr/share/nginx/html/$(PICTURE_FILENAME) \
		-v $(PWD)/$(DIST_DIR)/favicon.ico:/usr/share/nginx/html/favicon.ico \
		-p "127.0.0.1:12201:80" \
		nginx:alpine

gen-resume-pdf:
ifeq ($(UNAME), Darwin)
	sed -i "_tmp" "s|/$(PICTURE_FILENAME)|file://$(PWD)/$(DIST_DIR)/$(PICTURE_FILENAME)|g" "$(RESUME_JSON)"
	-rm "$(RESUME_JSON)_tmp"
	# on Mac Big Sur, for some reason, I had to navigate into this directory and npm install
	# the dependencies for hackmyresume - otherwise, it would just keep failing, saying
	# that one dependency wasn't installed every time I ran it (like playing whack-a-mole)
	-cd /opt/homebrew/lib/node_modules/hackmyresume && npm install
else ifeq ($(UNAME), Linux)
	sed -i "s|/$(PICTURE_FILENAME)|file://$(PWD)/$(DIST_DIR)/$(PICTURE_FILENAME)|g" "$(RESUME_JSON)"
else
	echo "Unrecognized platform. Please inspect the Makefile to alter this file manually."
	exit 1
endif
	hackmyresume -d build "$(RESUME_JSON)" TO $(DIST_DIR)/$(OUTPUT_FILENAME).pdf -t ./$(THEME_DIR)/
ifeq ($(UNAME), Darwin)
	sed -i "_tmp" "s|file://$(PWD)/$(DIST_DIR)/$(PICTURE_FILENAME)|/$(PICTURE_FILENAME)|g" "$(RESUME_JSON)"
	-rm "$(RESUME_JSON)_tmp"
else ifeq ($(UNAME), Linux)
	sed -i "s|file://$(PWD)/$(DIST_DIR)/$(PICTURE_FILENAME)|/$(PICTURE_FILENAME)|g" "$(RESUME_JSON)"
else
	echo "Unrecognized platform. Please inspect the Makefile to alter this file manually."
	exit 1
endif

build: reset-theme build-resume serve-resume gen-resume-pdf
