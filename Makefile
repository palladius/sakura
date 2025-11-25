
help:
	@echo 'clean:         TODO cleanup'
	@echo 'install:       Installs software'
	@echo 'test:          Runs tests'
	@echo 'autocomplete:  Fills the autocomplete scripts (eg gcutil)'
	@echo docker-build:   Builds latest Docker image locally
	@echo docker-push:    Pushes Docker images to palladius/sakura:latest
	@echo docker-run:     Runs locally in bash for testing

clean:
	echo TODO cleanup

install:
	sbin/make-install.sh

TEST_SUBDIRS =  lib/recipes/  docz/richelp/

# make test a phony target
.PHONY: clean
.PHONY: test
test:
	for dir in $(TEST_SUBDIRS); do \
		echo "Making1 subdir (pwd=`pwd`): $(MAKE) -C $$dir"; \
    $(MAKE) -C $$dir; \
		echo "Making2 subdir (pwd=`pwd`): $(MAKE) -C $$dir"; \
  done

test-ruby:
	rake test

autocomplete:
	make -C bashrc.d/services.d/autocomplete/gcutil.auto/

docker-build:
	docker build -t=palladius/sakura:latest .
docker-push: docker-build
	docker push palladius/sakura:latest
# doesnt work
docker-run:
	docker run -it -p 22180:80 --name sakura-on-apache2-local22180 palladius/sakura:latest # service apache2 start
docker-run2:
	docker run -P --name sakura-on-apache2-anyport49k palladius/sakura:latest
docker: docker-build docker-run
	echo Building and running... on port 22180