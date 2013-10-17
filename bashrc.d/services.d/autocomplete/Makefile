
# EVERYTHING except "gcutil.list.auto"
ALL_FILES = gcutil.help.auto gcutil.dashdashhelp.auto gcutil.images.auto gcutil.zones.auto

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



clean:
	rm -f $(ALL_FILES) gcutil.list.auto