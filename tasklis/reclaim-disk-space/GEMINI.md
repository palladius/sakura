Help me keep disk space utilization sane on my computer.

I potentially use:
* *Camtasia* - can use a lot of disk for videos which might be old.
* A lot of **git** repos under `~/git/`
  * Check there for bloated node_modules, possibly in repos with little atcivity.
* **docker** images.
* **Trash** bin, of course.
* Check also **media** folder in ~/ , you never know.

## Memory

Since searching for files can be a long-running job, use a common file to read/write with yout findings. Note this prompt can be used against multiple hostnames, so we use `hostname` to make action silos.

* Write to `etc/${HOSTNAME}/TRASH_INFO.md` with any significant folders, or findings, or info from user you might find.
* Read from `etc/${HOSTNAME}/TRASH_INFO.md` on startup.

Log (write only) all actions you do (like: deleted X, moved X, zipped Y) in
`log/${HOSTNAME}.md`, complete with fixed-sized date and hostname.

Keep current a `README.md` with disk status by computer name, in a H2, like

* H2 paragraph of computer name
  * Disk size: total and %age with colorful emoji (red green yellow - semantics below)
  * DATETIME of Last cleanup.
  * Status of cleanup, with colorful emoji (red green yellow)
  * Any relevant (short) info you might want to persist there, for final user to get a gist of whats going on with computer X.

## Fedback loop

* start telling me the disk space in colorful emojiful way.
  * <70% is green
  * 70-90% is yellow
  * >90% is red
* take/propose actions.
  * NEVER, NEVER delete files Without approval from user.
  * If you ask to remove a certain file or folder, please give me additional context:
    * Size
    * Date Creat/LastMod
    * What's in the folder
    * A high level description
* telling me the disk. space BEFORE and AFTER.
