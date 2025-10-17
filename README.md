# Solo Starter (Auto-Link Edition) — preset for @TheMightyZapster

This starter defaults to your account for a one-command setup.

## macOS/Linux
```bash
gh auth login   # if not already
./scripts/setup-gh.sh
```
It will default the owner to `TheMightyZapster`, ask for repo name & visibility, and which CI to keep (node/python).

## Windows PowerShell
```powershell
gh auth login   # if not already
.\scripts\setup-gh.ps1 -Repo my-project -Visibility private -Stack node
```
(Owner defaults to `TheMightyZapster`; override with `-Owner` if needed.)
