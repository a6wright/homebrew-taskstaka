# homebrew-taskstaka

Homebrew tap for [taskstaka](https://github.com/a6wright/taskstaka), a "what needs action next" task server backed by markdown.

```
brew install a6wright/taskstaka/taskstaka
taskstaka init
brew services start taskstaka      # daemon at login
taskstaka setup macos              # macOS: menu bar item + ⌥Space quick add (and the daemon, if brew services is not used)
```
