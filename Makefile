
help:
	@echo 'clean:         TODO cleanup'
	@echo 'install:       Installs software'
	@echo 'test:          Runs tests'

clean:
	echo TODO cleanup

install:
	sbin/make-install.sh

test:
	cd lib/recipes/ && make
