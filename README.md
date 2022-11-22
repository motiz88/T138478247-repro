# T138478247-repro

Minimal repro for a Metro bug.

```
scripts/repro.sh

### Setup (yarn, Metro)

yarn install v1.22.5
[1/4] 🔍  Resolving packages...
success Already up-to-date.
✨  Done in 0.17s.

### Initial build

Expected: Hello from main1.js
Actual: Hello from main1.js

### Build after changing package.json (same Metro instance)

Expected: Hello from main2.js
Actual: Hello from main1.js

### Build after changing package.json (new Metro instance)

Expected: Hello from main2.js
Actual: Hello from main2.js
```
