{
  description = "memory-forge dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # `gh stack` (stacked PRs, standard git-split-code-and-memory). nixpkgs ships the
        # extension as a bare `gh-stack` binary, which gh does not find as an extension, so
        # this `gh` forwards `gh stack ...` to it and everything else to the real gh.
        gh = pkgs.writeShellScriptBin "gh" ''
          if [ "''${1:-}" = stack ]; then shift; exec ${pkgs.gh-stack}/bin/gh-stack "$@"; fi
          exec ${pkgs.gh}/bin/gh "$@"
        '';
      in
      {
        # Only the tools the process needs: the task runner, GitHub CLI for
        # issues and PRs (with `gh stack`), and gitleaks for the secret-scan hook (decision 0008).
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.go-task
            gh
            pkgs.gitleaks
          ];

          # Enable the repo's git hooks (secret scan) on entry, so no clone needs
          # a manual step (decision 0008).
          shellHook = ''
            root=$(git rev-parse --show-toplevel 2>/dev/null) || root=
            if [ -n "$root" ] && [ -d "$root/.githooks" ]; then
              git -C "$root" config core.hooksPath .githooks
            fi
          '';
        };
      });
}
