# juliusolavarria.com: project notes for AI assistants

Read this first. It explains how the site is built, where it lives, and how the owner likes to work.

## What this is

Static website for Julius Olavarria's writing (philosophy, AI policy, legal op-eds, AP study guides).
Migrated from Google Sites in September 2026. Live at **https://juliusolavarria.com**; `www` redirects to it.
Plain HTML and CSS, no framework, no database.

## How the site is built

- `content/`: the pages you edit. One file per page: a small front-matter header (`title:`, `description:`) followed by the page's HTML.
- `build.rb`: wraps every file in `content/` with the shared head, menu and footer and writes the finished pages to the repo root (`index.html`, `ai/`, `archive/`, `featured-work/`, ...). Needs only Ruby (ships with macOS). The menu (`NAV`) and footer live in this file.
- `assets/css/style.css`: all styling. Fonts: Source Serif 4 (headings) and Inter (text).
- `assets/img/`: images. `<slug>-thumb.jpg` is the card thumbnail on list pages; `<slug>-s<section>-<n>.jpg` are images inside an article.
- **Never edit the generated pages by hand.** Edit `content/`, run `ruby build.rb`, then commit both `content/` and the regenerated pages.
- `tools/check_links.rb`: run after building. Reports any internal link or image that points at a missing file.

### Adding an article

1. Save the thumbnail (and any in-article images) in `assets/img/`. Use JPEG for photos; keep PNG only if it needs transparency.
2. Copy an existing article in `content/archive/<section>/` (or `content/featured-work/`) and change the front matter, heading, meta line (`<p class="article-meta">`) and text.
3. Add a `<article class="card">` for it to the section's list page (e.g. `content/archive/philosophy.html`). If it is featured, add a card to `content/index.html` and `content/featured-work.html` too.
4. `ruby build.rb`, then `ruby tools/check_links.rb`, then look at the page in a browser.
5. Commit. **Ask the owner before pushing** (see below).

## Hosting and deploys

- Source: GitHub repo `juliusolavarria-hue/juliusolavarria-site`, branch `main`.
- Host: Cloudflare (Workers static assets), project `juliusolavarria-site`. It redeploys automatically about a minute after each push to `main`.
- `wrangler.jsonc` tells Cloudflare the site is plain files in the repo root. `.assetsignore` keeps non-site files (`content/`, `build.rb`, `tools/`, notes) from being published. `_redirects` sends the old accented `māori` URL to its ASCII address.
- DNS is on Cloudflare (registrar: Namecheap). Records to **keep**: the five `eforward*.registrar-servers.com` MX records and the SPF TXT record (Namecheap email forwarding), and the `google-site-verification` TXT record. `www` is a proxied CNAME with a Redirect Rule (www to apex, 301). "Always Use HTTPS" is on.

## Working with the owner

- The owner is new to Git and hosting. Explain steps plainly and give exact clicks or commands.
- **Pushing publishes to the live site. Ask before every push**, even for small edits. Say what will change.
- Never ask the owner to paste passwords or tokens into chat. Git credentials are in the macOS keychain. Push without a prompt using `GIT_TERMINAL_PROMPT=0 git push`.
- Commit messages end with the co-author trailer the tooling asks for.
- After changing images, check for truncated files (a bad download once left images half black). JPEG files should end with bytes `ff d9`.
- Article titles and wording follow the owner's originals, including their quirks. Don't "correct" them without asking.

## Open items

- Four Google links on the AP Guides pages looked dead when checked in September 2026 (US History guide, Human Geography guide and spreadsheet, Art History "Official Guide"). Waiting on the owner for replacements or removal.
- Two Philosophy articles (Ethics of Inclusion, Honoring the Treaty) share the same picture. This came from the original site.
- The old Google Sites page is still published but no longer receives traffic. The owner will unpublish it when ready.
