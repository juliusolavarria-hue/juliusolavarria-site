#!/usr/bin/env ruby
# Checks that every internal link and image in the built site points at a file that exists.
#
#   ruby build.rb && ruby tools/check_links.rb
#
# Exits with a non-zero status if anything is broken.

ROOT = File.expand_path("..", __dir__)
Dir.chdir(ROOT)

pages = Dir["**/*.html"].reject { |f| f.start_with?("content/") || f.start_with?("tools/") }
bad = []
total = 0

pages.each do |f|
  File.read(f, encoding: "UTF-8").scan(/(?:href|src)="(\/[^"#?]*)/).flatten.each do |p|
    total += 1
    target = File.join(ROOT, p)
    ok = File.file?(target) || File.file?(File.join(target, "index.html"))
    bad << [f, p] unless ok
  end
end

puts "checked #{total} internal references in #{pages.size} pages"
if bad.empty?
  puts "no broken internal links or images"
else
  bad.uniq.each { |f, p| puts "BROKEN #{p}  (in #{f})" }
  exit 1
end
