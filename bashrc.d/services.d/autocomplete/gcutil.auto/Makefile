
# EVERYTHING except "gcutil.list.auto"
ALL_FILES = gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto gcutil.zones.auto \
 gcutil.projects.auto gcutil.firewalls.auto gcutil.instances.auto gcutil.machinetypes.auto \
 gcutil.kernels.auto gcutil.networks.auto gcutil.service_versions.auto

MOCK_FILES = *.mock

all: mock gcutil
	@echo Building ALL_FILES: $(ALL_FILES)
	@echo you can clean up stuff by this: make clean-bad-files

gcutil: gcutil.list
	echo Explicitly copying automatic list into list.
	cp gcutil.list.auto gcutil.list

gcutil.list: gcutil.list.auto
	cp gcutil.list.auto gcutil.list

gcutil.list.auto: $(ALL_FILES) 
	echo Merging all files: $(ALL_FILES)
	cat $(ALL_FILES) > gcutil.list.auto
	echo "Try: cp gcutil.list.auto gcutil.list"

gcutil.help.auto:
	gcutil help |  egrep -v '^$$' | egrep '^\w+( )+ [A-Z]' | awk '{print $$1}' | sort | xargs | tee gcutil.help.auto


#####################################################################################3
# entity completion: Start
#####################################################################################3

# gcutil --help options, starting wityh '--'
gcutil.dashdashhelp.auto:
	cat gcutil.dashdashhelp.mock | egrep -v '^#' | sort | tee gcutil.dashdashhelp.auto

gcutil.firewalls.auto:
	gcutil listfirewalls --format names | sort | tee gcutil.firewalls.auto

gcutil.images.auto:
	gcutil listimages --format names |xargs | sort | tee gcutil.images.auto

gcutil.instances.auto:
	# this should be LESS cached (eg 30')
	@echo "DEBUG Populating instances with gcutil listinstances... pleas ebe patient" >&2
	gcutil listinstances --format names | cut -d/ -f 3 | sort | tee gcutil.instances.auto

gcutil.kernels.auto:
	gcutil listkernels --format names |xargs | sort | tee gcutil.kernels.auto

gcutil.machinetypes.auto:
	gcutil listmachinetypes --format names | cut -f 3 -d/ | sort | tee gcutil.machinetypes.auto

gcutil.networks.auto:
	gcutil listnetworks --format names |xargs | sort | tee gcutil.networks.auto

gcutil.projects.auto:
	cat ~/.gcutil.flags | egrep -- '^--project=' | cut -f 2 -d= | tee gcutil.projects.auto

gcutil.service_versions.auto:
	cat gcutil.service_versions.mock  | egrep -v '^#' | sort >  gcutil.service_versions.auto
 
gcutil.zones.auto:
	gcutil listzones --format names |xargs | sort | tee gcutil.zones.auto

#####################################################################################3
# /entity completion
#####################################################################################3

clean: cache-invalidate clean-bad-files
	@echo Invalidating cached values older than a day:
	find . -name \*.auto -cmin +1440 -print0 | xargs -0 rm
	@echo To clean all, try: make clean-all

clean-all:
	rm -f *.auto gcutil-mock.list gcutil.list

clean-bad-files:
	@echo Looking for files which have 2 bytes or less: deleting them
	find . -name \*.auto -size -2c -print0 | xargs -0 -r rm -f

#############################################################
# Mocks

mock: gcutil-mock.list
	@echo Making gcutil-mock.list..

gcutil-mock.list:
	@echo Merging Mocks into one file:
	cat gcutil.*.mock | egrep -v '^#' | tee gcutil-mock.list

cache-invalidate:
	@echo Invalidating cached values older than a day:
	find . -name \*.auto -cmin +1440 -print0 | xargs -r -0 rm

