
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

# deploys gem
deploy:
	rake manifest && rake build_gemspec && rake release && rake publish_docs && verde Correctly deployed