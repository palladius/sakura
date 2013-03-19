# builds help into HTML :)

test:
	ymltest --no-color *yml
	@echo YML Test Return: $?

dropbox:
	$(GIC)/bin/make-help-to-dropbox 

all: test dropbox
