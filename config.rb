require "middleman-core"

###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = ""

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "/posts/{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "layouts/blog.html"
  blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes


# Use Directory structure
activate :directory_indexes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
helpers do
  def cleanup_readmore(html)
      html.sub(/(READMORE)/, "<span id='readmore'></span>")
  end

  def meta_tags
    @meta_tags ||= ActiveSupport::HashWithIndifferentAccess.new
  end

  def set_meta_tags(meta_tags = {})
    self.meta_tags.merge! meta_tags
  end

  def description(description = nil)
    set_meta_tags(description: description) unless description.nil?
  end

  def keywords(keywords = nil)
    set_meta_tags(keywords: keywords) unless keywords.nil?
  end

  def title(title = nil)
    set_meta_tags(title: title) unless title.nil?
  end

  def display_meta_tags(default = {})
    result    = []
    meta_tags = default.merge(self.meta_tags).with_indifferent_access

    title = full_title(meta_tags)
    meta_tags.delete(:title)
    meta_tags.delete(:separator)
    result << content_tag(:title, title) unless title.blank?

    description = safe_description(meta_tags.delete(:description))
    result << tag(:meta, name: :description, content: description) unless description.blank?

    keywords = meta_tags.delete(:keywords)
    result << tag(:meta, name: :keywords, content: keywords) unless keywords.blank?

    meta_tags.each do |name, content|
      if name.start_with?('og:')
        result << tag(:meta, property: name, content: content ) unless content.blank?
      else
        result << tag(:meta, name: name, content: content ) unless content.blank?
      end
    end

    result = result.join("\n")
    result.html_safe
  end

  def auto_display_meta_tags(default = {})
    auto_tag

    display_meta_tags default
  end

  def auto_tag
    site_data = (data['site'] || {}).with_indifferent_access

    set_meta_tags site: site_data['site']
    set_meta_tags 'og:site_name' => site_data['site']
    set_meta_tags 'og:type' => 'article'

    fall_through(site_data, :title, 'title')
    fall_through(site_data, :description, 'description')
    concat(site_data, :keywords, 'keywords', ', ')

    # Twitter cards
    fall_through(site_data, 'twitter:card', 'twitter_card', 'summary_large_image')
    fall_through(site_data, 'twitter:creator', 'twitter_author')
    fall_through(site_data, 'twitter:description', 'description')
    fall_through(site_data, 'twitter:image', 'pull_image')
    fall_through(site_data, 'twitter:site', 'publisher_twitter')
    fall_through(site_data, 'twitter:title', 'title')
    concat(site_data, 'twitter:url', 'url', '')

    # Open Graph
    fall_through(site_data, 'og:description', 'description')
    fall_through(site_data, 'og:image', 'pull_image')
    fall_through(site_data, 'og:title', 'title')
    concat(site_data, 'og:url', 'url', '')

  end

  private

  def fall_through(site_data, name, key, default = nil)
    value = self.meta_tags[key] || site_data[key] || default
    set_meta_tags name => value unless value.blank?
    value
  end

  def concat(site_data, name, key, separator = '')
    value = ''

    (value << site_data[key]) unless site_data[key].blank?
    (value << "#{separator}") unless self.meta_tags[key].blank?
    (value << self.meta_tags[key]) unless self.meta_tags[key].blank?

    set_meta_tags name => value unless value.blank?

    value
  end

  def full_title(meta_tags)
    separator   = meta_tags[:separator] || '|'
    full_title  = ''
    title       = safe_title(meta_tags[:title])

    (full_title << title) unless title.blank?
    (full_title << " #{separator} ") unless title.blank? || meta_tags[:site].blank?
    (full_title << meta_tags[:site]) unless meta_tags[:site].blank?
    full_title
  end

  def safe_description(description)
    #truncate(strip_tags(description), length: 200)
    strip_tags(description)
  end

  def safe_title(title)
    title = strip_tags(title)
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
