
help:
	@echo 'clean:         TODO cleanup'
	@echo 'install:       Installs software'
	@echo 'test:          Runs tests'
	@echo 'deploy:        Creates manifest, gemspecs, .. and deploys to rubygem'
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

# pre deploys gem
predeploy:
	(rake manifest && rake build_gemspec ) | tee .predeploy.out && verde Correctly built manifests and dependencies. Now commit and run deploy
# deploys gem
deploy:
	rake manifest && rake build_gemspec && rake release && rake publish_docs && verde Correctly deployed
autocomplete:
	make -C bashrc.d/services.d/autocomplete/gcutil.auto/

docker-build:
	docker build -t=palladius/sakura:latest .
docker-push: docker-build
	docker push palladius/sakura:latest
docker-run:
	docker run -it -p 22080:80 palladius/sakura:latest bash
