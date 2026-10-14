---
name: jenv-java-version
description: Fix wrong-Java-version problems using jenv (`jenv local <major>`). Use when a Java/Maven/Gradle command fails with a version error (UnsupportedClassVersionError, "release version N not supported", "invalid target release", "requires Java N", "class file version 65/69"), or when setting up development on a new or unfamiliar Java repo, before the first build or test run.
---

Read this if you are about to run, build, or test Java code, and the active JDK might not match what the repo needs.
Melody manages JDKs with [jenv](https://www.jenv.be/). Fix versions *per repo* with `jenv local`, never by editing global config.

## 1. Find out what's needed vs. what's active

Needed (check in roughly this order; stop when sources agree):
- the error message itself: class file versions map to Java as 52=8, 55=11, 61=17, 65=21, 69=25
- `.java-version` or `.tool-versions` in the repo (jenv may already be configured)
- README "Requirements" section
- `pom.xml` / parent poms: `java.version`, `maven.compiler.release|source|target`, enforcer `requireJavaVersion`; Gradle: `toolchain`, `sourceCompatibility`
- Dockerfile / CI config (Jenkinsfile, pipeline files) / Lambda runtime config

If sources disagree, say so to Melody rather than picking one.

Active, and what's installed:
```bash
jenv version     # active version and *why* (global file, .java-version, shell)
jenv versions    # installed JDKs jenv knows about
java -version; mvn -v   # what actually runs — jenv version alone can lie (see lazy-loading)
```

## 2. Set it

Use a single **major** version, in the repo directory:
```bash
jenv local 25
```
Use a full version or vendor (e.g. `openjdk64-25.0.2`) only when it matters: a bug or behavior in a specific patch release, or a repo/README that mandates a vendor. Say why when you do.

Don't use `jenv global` (changes every project) or `jenv shell` (doesn't persist across tool calls). `jenv local` writes `.java-version` in the repo, which persists across tool calls.

`.java-version` is a new file in the working tree. Check whether the repo ignores or tracks it (`git check-ignore .java-version`). If not ignored, tell Melody; don't commit it unasked. Melody uses jj, which snapshots untracked files automatically, so it will otherwise silently land in the working-copy commit. `.git/info/exclude` is a good local-only fix; suggest it rather than editing the repo's `.gitignore` unasked.

If the needed major isn't in `jenv versions`, it isn't installed (or isn't registered):
1. `ls /opt/homebrew/Cellar | grep -i openjdk`, or `brew search openjdk`
2. Tell Melody what you'd install and ask before `brew install openjdk@<n>`.
3. Register it: `jenv add <path-to-home>` (Homebrew: `/opt/homebrew/Cellar/openjdk@<n>/<ver>/libexec/openjdk.jdk/Contents/Home`; plain `openjdk` is the latest major). A bare `jenv versions` entry may point to a dangling symlink in `~/.jenv/versions` if the brew formula was removed/upgraded: check with `ls -L ~/.jenv/versions/<n>`.

## 3. Verify

Run `java -version` **and** `mvn -v` (or the Gradle equivalent) *in the repo directory* and confirm the major version matches; then retry the original command.
<<<<<<< HEAD
Check both: they can disagree (see "stale JAVA_HOME" below; on Melody's machine `~/.mavenrc` should keep `mvn` correct on its own). For non-Maven tools, after `jenv local` the safest pattern is a fresh init in the same command as the real work:
=======
Check both: they can disagree (see "stale JAVA_HOME" below). After `jenv local`, the safest pattern is a fresh init in the same command as the real work:
>>>>>>> 76b4e1c (feat: agent skill for managing java version via jenv)
```bash
eval "$(jenv init -)" && mvn -v && mvn clean verify
```

## Melody's shell: jenv is lazy-loaded

`~/.config/zsh/.zpath` lines 63-65:
```zsh
local jenv_shims=(~/.jenv/shims/*(N:t))
lazyload jenv mvn $jenv_shims -- 'eval "$(jenv init -)"'
```
`jenv`, `mvn`, and every command that had a shim in `~/.jenv/shims` *when the shell started* are stub functions. The first call runs `eval "$(jenv init -)"` (puts shims on PATH, sets JAVA_HOME via the export plugin), then re-dispatches. Consequences:

- **Plain `java`/`mvn` can resolve to something else** if init hasn't run: `/usr/bin/java` (the macOS stub) or a Homebrew `java` directly, giving the "wrong" version despite a correct `.java-version`. `which -a java` showing a *function* is the lazy stub (normal); showing only `/usr/bin/java` means lazyload isn't active in this shell.
- **Commands without a shim at shell start aren't lazy-wrapped** (e.g. a tool installed or `jenv rehash`ed after the shell began, or `gradle`, `kotlin`, etc. not in the list), so they bypass jenv until init has run.
- **Non-zsh / non-interactive shells** (scripts, `bash -c`, some tool runners) don't read `.zpath`, so there's no lazyload at all, and also no jenv.
- **Stale `JAVA_HOME` (observed, journey-session-store):** init exports `JAVA_HOME` (export plugin) *once*, based on the version in effect at that moment. If the first jenv/java/mvn call in a shell triggers init and `jenv local 25` runs afterward in the same shell, `JAVA_HOME` stays at the old global (17). The jenv *shim* (`java`) re-reads `.java-version` and says 25, but `mvn` honors `JAVA_HOME` and still runs 17. Symptom: `java -version` and `mvn -v` disagree, and the build keeps failing with the original error. Fix: re-run `eval "$(jenv init -)"` after `jenv local` (or start a new shell/tool call).
- **Without any init**, nothing is jenv-aware: `java` resolves to the system JDK, and Homebrew's `mvn` wrapper falls back to the *latest* Homebrew `openjdk` (27 at time of writing), which is neither the pinned nor the global version.

<<<<<<< HEAD
**Maven is covered separately on this machine:** `~/.mavenrc` sets `JAVA_HOME="$(jenv javahome)"` on every `mvn` run (real binary, so no init needed; recomputed each time, so never stale). So `mvn` should follow `.java-version` regardless of the issues above. Costs ~0.2s per run; bypass with `MAVEN_SKIP_RC=1`. If `mvn -v` disagrees with `.java-version` anyway, check that the file still exists and that `MAVEN_SKIP_RC` isn't set. This does not cover other `JAVA_HOME` consumers (Gradle, IDEs, scripts), so the init workaround below still applies to them.

=======
>>>>>>> 76b4e1c (feat: agent skill for managing java version via jenv)
**Workaround whenever something looks off**: initialize explicitly, in the same command:
```bash
eval "$(jenv init -)" && java -version && mvn -v
```
If that fixes it, the lazy-loading was the cause: tell Melody which command wasn't covered, so the lazyload line can be adjusted if it's worth it. Don't edit `.zpath` yourself.

`jenv doctor` reports whether jenv is correctly loaded and whether shims precede other Javas on PATH.

## Related pitfalls

- `JAVA_HOME` set by something else (IDE, sdkman, `.zshenv`) overrides jenv: `echo $JAVA_HOME`. The jenv `export` plugin should manage it (`jenv enable-plugin export`).
<<<<<<< HEAD
- Maven running a different JDK than `java`: check `mvn -v` "Java version", `~/.mavenrc` (see above), `MAVEN_SKIP_RC`, and `/opt/homebrew/etc/mavenrc`.
=======
- Maven running a different JDK than `java`: check `mvn -v` "Java version" and `~/.mavenrc`.
>>>>>>> 76b4e1c (feat: agent skill for managing java version via jenv)
- Maven daemons or IDE processes started under the old JDK keep it until restarted.
