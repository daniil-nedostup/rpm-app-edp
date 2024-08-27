CURRENT_DIR=$(shell pwd)
DIST_DIR=${CURRENT_DIR}/dist
BIN_DIR=target

NAME ?= rpm-java-app-edp
ARCH ?= x86_64
VERSION ?= 0.0.0
RELEASE ?= SNAPSHOT.1
BINARY_EXTENSION = .jar

prepare:
	mkdir -p rpmbuild/SOURCES
	mkdir -p ${DIST_DIR}/$(NAME)-$(VERSION)
	cp -r ${BIN_DIR}/*${BINARY_EXTENSION} ${DIST_DIR}/$(NAME)-$(VERSION)/${NAME}
	cp -r ${NAME}.service rpmbuild/SOURCES/$(NAME).service
	tar -czvf rpmbuild/SOURCES/$(NAME)-$(VERSION).tar.gz -C ${DIST_DIR} $(NAME)-$(VERSION)

rpm-build: prepare
	rpmbuild -bb $(NAME).spec \
	        --define "_topdir ${CURRENT_DIR}/rpmbuild" \
	        --define "SRC ${CURRENT_DIR}" \
	        --define "VERSION_NUMBER $(VERSION)" \
	        --define "RELEASE_NUMBER $(RELEASE)"
	mv rpmbuild/RPMS/$(ARCH)/$(NAME)-$(VERSION)-$(RELEASE).$(ARCH).rpm $(DIST_DIR)

publish:
	curl --user "${CI_USERNAME}:${CI_PASSWORD}" \
		--upload-file ./dist/${NAME}-${VERSION}-${RELEASE}.x86_64.rpm \
		${NEXUS_HOST_URL}/repository/edp-yum-snapshots/x86_64/os/Packages/

clean:
	rm -rf ${DIST_DIR}
	rm -rf rpmbuild
	rm -rf ${BIN_DIR}
	rm -f $(NAME)-$(VERSION)-$(RELEASE).$(ARCH).rpm

rpm-lint:
	rpmlint -c .rpmlintrc.toml $(NAME).spec
