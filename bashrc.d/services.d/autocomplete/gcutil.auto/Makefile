
# EVERYTHING except "gcutil.list.auto"
ALL_FILES = gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto gcutil.zones.auto  gcutil.projects.auto gcutil.firewalls.auto
MOCK_FILES = *.mock

all: mock gcutil
	@echo Building ALL_FILES: $(ALL_FILES)

gcutil: gcutil.list
	echo Explicitly copying automatic list into list.
	cp gcutil.list.auto gcutil.list

gcutil.list: gcutil.list.auto
	cp gcutil.list.auto gcutil.list

gcutil.list.auto: $(ALL_FILES) 
# gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto gcutil.zones.auto gcutil.projects.auto
#gcutil.list.auto: gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto
	echo Merging all files: $(ALL_FILES)
	cat $(ALL_FILES) > gcutil.list.auto
	echo "Try: cp gcutil.list.auto gcutil.list"

#OK
gcutil.help.auto:
	gcutil help |  egrep -v '^$$' | egrep '^\w+( )+ [A-Z]' | awk '{print $$1}' | sort | xargs | tee gcutil.help.auto

# ok
gcutil.dashdashhelp.auto:
	cat gcutil.dashdashhelp | egrep -v '^#' | tee gcutil.dashdashhelp.auto

# OK
gcutil.images.auto:
	gcutil listimages --format names |xargs | tee gcutil.images.auto
 
gcutil.zones.auto:
	gcutil listzones --format names |xargs | tee gcutil.zones.auto

gcutil.firewalls.auto:
	gcutil listfirewalls --format names | tee gcutil.firewalls.auto

gcutil.projects.auto:
	cat ~/.gcutil.flags | egrep -- '^--project=' | cut -f 2 -d= | tee gcutil.projects.auto

mock: gcutil-mock.list

gcutil-mock.list:
	@echo Merging Mocks into one file:
	cat gcutil.*.mock | egrep -v '^#' | tee gcutil-mock.list

clean:
	rm -f *.auto gcutil-mock.list
