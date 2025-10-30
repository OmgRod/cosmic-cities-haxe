````markdown name=README_DEPENDENCY_SETUP.md
```markdown
## Dependency setup with HMM

This project now includes an hmm.json to pin and install dependencies used by the game. HMM can fetch both haxelib versions and git repositories.

To bootstrap dependencies:

1. Install HMM:
   ```bash
   haxelib --global install hmm
   haxelib --global run hmm setup
   ```
2. From the repository root:
   ```bash
   ./tools/setup-deps.sh
   ```

3. Build the project as usual:
   - lime test windows
   - lime test html5

Notes:
- If you prefer haxelib versions over git pins, edit `hmm.json` to change entries to type `haxelib` and set `version`.
- Keep `hmm.json`, `project.hxp` and your `project.xml` (if present) in sync.
```
````