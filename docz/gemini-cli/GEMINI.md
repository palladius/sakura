I have a list of demos I do for Gemini CLI which I want to share with EVERYONE.

I want to make sure that the local README is up to date, and very nice and easy to consume by external parties.

## Your task

1. Read/Consume files: `demos/*.md`
2. If you find any inconsistency/errors/missing info, prompt user (Riccardo) to fix them.
3. Change README.md and update it to ensure there's an ordered table (01, 02, ..) with a few columns:
   1. Link: linked link to demo (eg "demos/01_sqlite.md")
   2. topic: Short Topic, like SQLite, git
   3. Short description.
4. Keep a justfile for Riccardo to QUICKLY open the demo locally. This is usually a combination of 2 commands:
   1. code <REPO_FOLDER>
   2. code add/-a "path/to/demo.md" (path is relative to repo folder)


## Examples

For demo01, open vscode at the  folder:  ~/git/gemini-cli-demos/demos/sqlite-investigation
Then tell vscode to open directly ONLY the file DEMO_SCRIPT.md if possible.

```bash
    code ~/git/gemini-cli-demos/demos/sqlite-investigation
    code DEMO_SCRIPT.md
```
