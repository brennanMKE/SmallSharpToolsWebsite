# Small Sharp Tools

Source for [www.smallsharptools.com](https://www.smallsharptools.com/), a single static page showcasing Mac apps, web tools, games, LED builds and agent skills by Brennan Stehling.

## Structure

- `site/` is what gets published. `index.html` is the entire site (inline CSS, no build step), and `images/` holds the icons, screenshots and photos.
- `scripts/` holds the tools below. They are never uploaded.
- `raw/` holds full-size originals. It is git-ignored and never uploaded.

## Scripts

| Script | What it does |
|---|---|
| `scripts/preview.sh` | Serves `site/` at <http://localhost:8000> and opens it. |
| `scripts/add-image.sh raw/Photo.png name` | Writes `site/images/name.jpg`, a JPEG at most 1200 px on the long side. |
| `scripts/deploy.sh` | Shows what would change on the server, asks, uploads `site/`, then runs `verify.sh`. `--dry-run` only shows the changes; `--yes` skips the question (use it when there is no terminal to answer, such as `!` in Claude Code). |
| `scripts/verify.sh` | Checks the live site from the internet: the page, every image it references, that `README.md` and `scripts/` are not served, the redirects and the certificate. |

## Hosting

The site is served by Apache on photon from `/var/www/vhosts/www.smallsharptools.com`, uploaded over ssh with the `photon` alias (override with `EC2_HOST`).

These all redirect to `https://www.smallsharptools.com/`:

- `smallsharptools.com`, any path, kept
- `http://` for either name
- the root path of `sstools.co` and `www.sstools.co` (other sstools.co paths and subdomains are unchanged)

The Apache vhosts, DNS records and the Let's Encrypt certificate (webroot, renews automatically) are managed in the AWS repo, not here.

## License

MIT, see [LICENSE](LICENSE).
