
# EVERYTHING except "gcutil.list.auto"
ALL_FILES = gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto gcutil.zones.auto gcutil.version.auto

all: $(ALL_FILES)
	echo Building all

gcutil.list: gcutil.list.auto
	echo Explicitly copying automatic list into list.
	cp gcutil.list.auto gcutil.list

gcutil.list.auto: $(ALL_FILES) gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto
#gcutil.list.auto: gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto
	echo Merging all files: $(ALL_FILES)
	cat $(ALL_FILES) > gcutil.list.auto
	echo "Try: cp gcutil.list.auto gcutil.list"

#OK
gcutil.help.auto:
	gcutil help |  egrep -v '^$$' | egrep '^\w+( )+ [A-Z]' | awk '{print $$1}' | sort | xargs | tee gcutil.help.auto

# ok
gcutil.dashdashhelp.auto:
	cat gcutil.dashdashhelp | egrep -v '^#' | gcutil.dashdashhelp.auto

# OK
gcutil.images.auto:
	gcutil listimages --format names |xargs | tee gcutil.images.auto
 
gcutil.zones.auto:
	gcutil listzones --format names |xargs | tee gcutil.zones.auto

# only works out of Google
gcutil.version.auto:
	gcutil version | tee gcutil.version.auto

clean:
	rm -f $(ALL_FILES) gcutil.list.auto