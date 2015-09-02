require "middleman-api/middleware"
require "active_support/core_ext"
require "middleman-core/sitemap/resource"
require "rack/test"

# Extension namespace
module Middleman::Api
  class Extension < ::Middleman::Extension
    # Specific paths to render as :formats
    option :paths, []

    # ignore metadata keys
    option :ignore_metadata_keys, []

    # Path to custom template (should probably be ERB)
    option :template, nil

    def initialize(app, options={})
      super
      @ready = false
    end

    def after_configuration
      fix_templates_for_filewatcher!
      app.ignore options.template

      app.set :api_resources, []

      app.use Middleman::Api::Middleware, app: app, options: options

      @ready = true
    end

    def manipulate_resource_list(resources)
      return resources unless @ready && app.build? && options[:build]

      api_resources = []
      resources.each do |resource|
        next if should_ignore_resource?(resource)
        next if options.paths.any? && !matches_paths_to_include?(resource)

        api_resources << add_request_endpoint(resource)
      end

      app.set :api_resources, api_resources

      return resources + api_resources
    end

    def add_request_endpoint(resource)
      path = formatted_path(resource)

      Middleman::Sitemap::Extensions::RequestEndpoints::EndpointResource.new(
        app.sitemap, path, path)
    end

    def formatted_path(resource)
      if resource.url == '/' || !(resource.path =~ /index\.html$/)
        path_base = "#{resource.destination_path.split('.').first}"
      else
        path_base = "#{resource.destination_path.split('/')[0..-2].join('/')}"
      end

      if app.extensions.include?(:directory_indexes)
        path_base.gsub!("/index", "")
      end

      [path_base, 'json'].join('.')
    end

    def fix_templates_for_filewatcher!
      extension_templates_dir = File.expand_path('../', __FILE__)
      templates_dir_relative_from_root = Pathname(extension_templates_dir)
        .relative_path_from(Pathname(app.root))
      app.files.reload_path(templates_dir_relative_from_root)
    end

    def matches_paths_to_include?(resource)
      options.paths.each do |path|
        next unless resource.path =~ %r[^#{path}] || resource.destination_path =~ %r[^#{path}]
        return true; break
      end
      return false
    end

    def should_ignore_resource?(resource)
      return true if resource.is_a? ::Middleman::Sitemap::Extensions::RequestEndpoints::EndpointResource
      return true if resource.ignored? || resource.ext == '.json'
      return true if Middleman::Util.path_match(app.images_dir, resource.path)
      return true if Middleman::Util.path_match(app.js_dir, resource.path)
      return true if Middleman::Util.path_match(app.css_dir, resource.path)
      return true if Middleman::Util.path_match(app.fonts_dir, resource.path)
      return true unless resource.template?
      return false
    end


    ::Middleman::Extensions.register(:api, Middleman::Api::Extension)
  end
end
