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
      in
      {
        # Only the tools the process needs: the task runner, GitHub CLI for
        # issues and PRs, and gitleaks for the secret-scan hook (decision 0008).
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.go-task
            pkgs.gh
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
