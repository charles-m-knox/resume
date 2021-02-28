

# gets used like .pdf or .all
OUTPUT_FILENAME=index

# can be all instead
OUTPUT_FILE_TYPE=html

# must be stored in the "pictures" directory
PICTURE_FILENAME=TechLife23.png

THEME_DIR=jsonresume-theme-elegant
DIST_DIR=docs
RESUME_JSON=resume.json
PWD=$(shell pwd)

CONTAINER_NAME=resume-nginx

reset-theme:
	-rm -rf $(THEME_DIR)
	git clone https://github.com/mudassir0909/jsonresume-theme-elegant $(THEME_DIR)
	cd $(THEME_DIR); npm install
	sed -i 's|//unpkg.com/jsonresume-theme-elegant@@{theme-version}/assets/icomoon/fonts|https://unpkg.com/jsonresume-theme-elegant@@{theme-version}/assets/icomoon/fonts|g' ./$(THEME_DIR)/assets/less/icon.less
	cd $(THEME_DIR); grunt build

build-resume:
	hackmyresume -d build "$(RESUME_JSON)" TO $(DIST_DIR)/$(OUTPUT_FILENAME).$(OUTPUT_FILE_TYPE) -t ./$(THEME_DIR)/

# note: serve-resume requires that the OUTPUT_FILENAME is either "html" or "all"
# (without quotes)
serve-resume:
	docker rm -f "${CONTAINER_NAME}" || true
	docker run \
    	-it \
    	-d \
    	--name "${CONTAINER_NAME}" \
    	--restart unless-stopped \
    	-v $(PWD)/dist/$(OUTPUT_FILENAME).html:/usr/share/nginx/html/index.html \
    	-v $(PWD)/pictures/$(PICTURE_FILENAME):/usr/share/nginx/html/$(PICTURE_FILENAME) \
    	-p "127.0.0.1:12201:80" \
    	nginx:alpine

gen-resume-pdf:
	sed -i "s|/$(PICTURE_FILENAME)|file://${PWD}/pictures/$(PICTURE_FILENAME)|g" "$(RESUME_JSON)"
	hackmyresume -d build "$(RESUME_JSON)" TO $(DIST_DIR)/$(OUTPUT_FILENAME).pdf -t ./$(THEME_DIR)/
	sed -i "s|file://${PWD}/pictures/$(PICTURE_FILENAME)|/$(PICTURE_FILENAME)|g" "$(RESUME_JSON)"

build: reset-theme build-resume serve-resume gen-resume-pdf
