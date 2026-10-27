class Taskstaka < Formula
  desc "What-needs-action-next task server backed by markdown, with a menu bar item"
  homepage "https://github.com/a6wright/taskstaka"
  url "https://github.com/a6wright/taskstaka/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "5780b27a660a2a62d50d573726a21a570dfb96ed6a7c98e3c0b88bdbea632c1f"
  license "MIT"
  head "https://github.com/a6wright/taskstaka.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/taskstaka")
    system "cargo", "install", *std_cargo_args(path: "crates/tray") if OS.mac?
  end

  # The daemon. `crashed: true` (not `keep_alive true`) so `taskstaka stop` sticks;
  # taskstaka's own stop/restart/status recognise the sh.brew.taskstaka label.
  service do
    run [opt_bin/"taskstaka", "serve"]
    keep_alive crashed: true
    log_path var/"log/taskstaka.log"
    error_log_path var/"log/taskstaka.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Start the daemon at login with either
        brew services start taskstaka          # daemon only
      or the menu bar item (quick-add key) plus the daemon:
        taskstaka setup macos                  # macOS: ⌥Space
        taskstaka setup linux                  # Linux: Alt+Space on GNOME; the item itself comes from source:
          sudo apt install libgtk-3-dev libwebkit2gtk-4.1-dev   # or gtk3-devel webkit2gtk4.1-devel
          cargo install --locked --git https://github.com/a6wright/taskstaka --tag v0.1.4 taskstaka-tray
      Or everything in one line: curl -fsSL https://taskstaka.com/install.sh | sh
      Your notes live in ~/todo (taskstaka init). Claude Code: taskstaka setup claude
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/taskstaka --version")
    ENV["TASKSTAKA_DIR"] = testpath/"todo"
    ENV["TASKSTAKA_CONFIG_DIR"] = testpath/"cfg"
    ENV["TASKSTAKA_DIRECT"] = "1"
    system bin/"taskstaka", "init"
    system bin/"taskstaka", "add", "Brew test task"
    assert_match "Brew test task", shell_output("#{bin}/taskstaka next")
    assert_path_exists testpath/"todo/index.md"
  end
end
