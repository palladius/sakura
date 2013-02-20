
help:
	@echo 'clean:         TODO cleanup'
	@echo 'install:       Installs software'
	@echo 'test:          Runs tests'
	@echo 'deploy:        Creates manifest, gemspecs, .. and deploys to rubygem'

clean:
	echo TODO cleanup

install:
	sbin/make-install.sh

test:
	cd lib/recipes/ && make

# pre deploys gem
predeploy:
	(rake manifest && rake build_gemspec ) | tee .predeploy.out && verde Correctly built manifests and dependencies. Now commit and run deploy
# deploys gem
deploy:
	rake manifest && rake build_gemspec && rake release && rake publish_docs && verde Correctly deployed
