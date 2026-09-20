# juliusolavarria.com

Static site for [juliusolavarria.com](https://juliusolavarria.com). Plain HTML and CSS, no framework, no database.

## How it's organised

| Path | What it is |
| --- | --- |
| `content/` | The pages you edit. One file per page, a small header (`title`, `description`) followed by the page's HTML. |
| `assets/css/style.css` | All styling. |
| `assets/img/` | Images. |
| `build.rb` | Wraps every file in `content/` with the shared header, menu and footer, and writes the finished pages. |
| everything else | Generated output (`index.html`, `ai/`, `archive/`, ...). Don't edit these by hand. |

## Build

Needs Ruby, which comes with macOS. No installs.

```bash
ruby build.rb
```

Then open `index.html` in a browser, or run a local server so links between pages work:

```bash
ruby -run -e httpd . -p 8000
```

and visit http://localhost:8000.

## Add an article

1. Put the thumbnail in `assets/img/`.
2. Copy an existing file in `content/archive/<section>/` or `content/featured-work/`, then change the title, description and text.
3. Add a card for it to the section's list page (for example `content/archive/philosophy.html`) and, if it's featured, to `content/index.html` and `content/featured-work.html`.
4. Run `ruby build.rb` and commit.

## Change the menu or footer

Edit `NAV` or the footer in `build.rb`, then run it again. Every page updates.
