# Dyuti OS — update / security backbone (APT repo)

Your own signed APT repository. This is the **sovereignty + monetization control
point**: updates, security patches, Pro packages, and edition gating all flow
through infra *you* run, hosted in India.

## Pieces

| File | Role |
|---|---|
| `config.sh` | repo name, suite, signing identity, **public URL** (set to your India server) |
| `setup-repo.sh` | one-time: generate GPG key, export public key, create + publish the repo |
| `add-package.sh` | add `.deb`(s) and re-publish (signed) |
| `client/dyuti.sources` | the APT source clients use (deb822) |
| `client/build-keyring-deb.sh` | builds `dyuti-archive-keyring.deb` (key + source) for the ISO |
| `keys/` | exported public key (created by `setup-repo.sh`) |

## First run (on your repo server, Linux)

```bash
sudo apt install -y aptly gnupg
# point config.sh REPO_PUBLIC_URL at your server, then:
./setup-repo.sh                       # makes the signing key + empty signed repo
./client/build-keyring-deb.sh         # builds the client keyring .deb
```

## Publish updates

```bash
./add-package.sh /path/to/some.deb    # add + re-sign + re-publish
# then deploy the tree:
rsync -a --delete "$HOME/.aptly/public/" user@your-india-server:/var/www/dyuti/
```
Serve `/var/www/dyuti` over HTTPS (nginx/Caddy) at the `REPO_PUBLIC_URL`.

## Wire updates into the OS

Bundle `client/out/dyuti-archive-keyring.deb` into the ISO and install it in the
chroot (add a stage that copies + `apt-get install`s it). Then every installed
Dyuti system trusts your key and pulls signed updates from your repo — the
foundation for security updates, Pro features, and support entitlements.

## Security notes
- Keep the **private signing key** offline / in an HSM for production; the
  `%no-protection` batch here is for bootstrapping only — add a passphrase and
  protect it before going live.
- Rotate keys with a documented procedure; ship new keys via keyring updates.
- This is the artifact auditors/government buyers will ask about — document the
  key custody chain.
