#!/usr/bin/env ruby
# Builds the static site: wraps every file in content/ with the shared header, nav and footer.
#
#   ruby build.rb
#
# content/index.html          -> index.html
# content/ai.html             -> ai/index.html
# content/archive/history/x.html -> archive/history/x/index.html
# content/404.html            -> 404.html
#
# Each content file starts with a small front-matter block:
#   ---
#   title: Page title
#   description: One-sentence summary (optional)
#   ---
# followed by the page's HTML.

require "cgi"
require "fileutils"

ROOT     = __dir__
CONTENT  = File.join(ROOT, "content")
SITE_URL = "https://juliusolavarria.com"
SITE     = "Julius Olavarria"
DEFAULT_DESCRIPTION = "Julius Olavarria — political and moral philosophy undergraduate at Penn, writing on AI policy, governance and ethics."
NEWSLETTER = "https://substack.com/@juliusolavarria"

NAV = [
  { label: "Featured Work", href: "/featured-work/" },
  { label: "AI",            href: "/ai/" },
  { label: "Archive",       href: "/archive/", children: [
    { label: "Philosophy",  href: "/archive/philosophy/" },
    { label: "Legal Op-Ed", href: "/archive/legal-op-ed/" },
    { label: "History",     href: "/archive/history/" },
    { label: "Education",   href: "/archive/education/" },
    { label: "Society",     href: "/archive/society/" },
  ] },
  { label: "AP Guides",     href: "/ap-guides/", children: [
    { label: "AP Government and Politics", href: "/ap-guides/ap-government-and-politics/" },
    { label: "AP European History",        href: "/ap-guides/ap-european-history/" },
    { label: "AP Human Geography",         href: "/ap-guides/ap-human-geography/" },
    { label: "AP United States History",   href: "/ap-guides/ap-united-states-history/" },
    { label: "AP Art History",             href: "/ap-guides/ap-art-history/" },
  ] },
  { label: "Contact",       href: "/contact/" },
].freeze

def esc(s)
  CGI.escapeHTML(s.to_s)
end

def parse(file)
  raw = File.read(file, encoding: "UTF-8")
  meta = {}
  body = raw
  if raw.start_with?("---\n")
    head, body = raw.sub(/\A---\n/, "").split(/^---\n/, 2)
    head.each_line do |line|
      k, v = line.chomp.split(": ", 2)
      meta[k] = v if k && v
    end
  end
  [meta, body.to_s]
end

def url_path_for(rel)
  return "/404.html" if rel == "404.html"
  return "/" if rel == "index.html"
  "/" + rel.sub(/\.html\z/, "") + "/"
end

def out_file_for(rel)
  return File.join(ROOT, rel) if rel == "index.html" || rel == "404.html"
  File.join(ROOT, rel.sub(/\.html\z/, ""), "index.html")
end

def current?(item, path)
  item[:href] == path || (item[:children] && path.start_with?(item[:href]))
end

def nav_html(path)
  items = NAV.map do |item|
    cur = current?(item, path) ? ' aria-current="page"' : ""
    kids = ""
    if item[:children]
      kids = %(<ul class="sub">#{item[:children].map { |c|
        %(<li><a href="#{c[:href]}"#{c[:href] == path ? ' aria-current="page"' : ""}>#{esc(c[:label])}</a></li>)
      }.join}</ul>)
    end
    %(<li><a href="#{item[:href]}"#{cur}>#{esc(item[:label])}</a>#{kids}</li>)
  end
  items.join("\n        ")
end

def page_html(meta, body, path)
  title = meta["title"] || SITE
  full_title = path == "/" ? SITE : "#{title} | #{SITE}"
  desc = meta["description"] || DEFAULT_DESCRIPTION
  canonical = path == "/404.html" ? nil : SITE_URL + path
  <<~HTML
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>#{esc(full_title)}</title>
      <meta name="description" content="#{esc(desc)}">
      #{canonical ? %(<link rel="canonical" href="#{canonical}">) : '<meta name="robots" content="noindex">'}
      <meta property="og:site_name" content="#{SITE}">
      <meta property="og:title" content="#{esc(full_title)}">
      <meta property="og:description" content="#{esc(desc)}">
      <meta property="og:type" content="#{path.count('/') > 2 ? 'article' : 'website'}">
      #{canonical ? %(<meta property="og:url" content="#{canonical}">) : ""}
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&family=Source+Serif+4:ital,wght@0,400;0,600;0,700;1,400&display=swap">
      <link rel="stylesheet" href="/assets/css/style.css">
    </head>
    <body>
      <a class="skip" href="#main">Skip to content</a>
      <header class="bar">
        <div class="bar__inner">
          <a class="bar__title" href="/">#{SITE}</a>
          <input class="burger" type="checkbox" id="burger" aria-label="Toggle menu">
          <label class="burger-btn" for="burger">Menu</label>
          <nav aria-label="Main">
            <ul class="menu">
            #{nav_html(path)}
            </ul>
          </nav>
        </div>
      </header>
      <main id="main">
    #{body.rstrip}
      </main>
      <footer class="foot">
        <div class="foot__inner">
          <p>Site owned and managed by #{SITE}, 2023–#{Time.now.year}</p>
          <nav aria-label="Footer">
            <a href="/contact/">Contact</a>
            <a href="/featured-work/">Featured articles</a>
            <a href="#{NEWSLETTER}" target="_blank" rel="noopener">Newsletter</a>
          </nav>
        </div>
      </footer>
    </body>
    </html>
  HTML
end

# ---------------------------------------------------------------------------

urls = []
Dir[File.join(CONTENT, "**", "*.html")].sort.each do |file|
  rel  = file.sub("#{CONTENT}/", "")
  meta, body = parse(file)
  path = url_path_for(rel)
  out  = out_file_for(rel)
  FileUtils.mkdir_p(File.dirname(out))
  File.write(out, page_html(meta, body, path))
  urls << path unless path == "/404.html"
end

sitemap = urls.map { |u| "  <url><loc>#{SITE_URL}#{u}</loc></url>" }.join("\n")
File.write(File.join(ROOT, "sitemap.xml"), %(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n#{sitemap}\n</urlset>\n))
File.write(File.join(ROOT, "robots.txt"), "User-agent: *\nAllow: /\n\nSitemap: #{SITE_URL}/sitemap.xml\n")

puts "Built #{urls.size} pages."
