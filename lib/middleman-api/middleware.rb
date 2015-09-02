module Middleman
  module Api
    class Middleware

      def initialize(app, options)
        @app     = app
        @options = options
      end

      def call(env)
        status, @headers, @body = @app.call(env)

        request_path = env["PATH_INFO"]
        json_path    = normalize_request_path(request_path.gsub(/\.json/, ''))

        if status == 404 && request_path.match(/\.json$/) && matches_paths_to_include?(request_path)
          env["PATH_INFO"] = json_path
          status, @headers, @body = @app.call(env)

          rewrite_content_type

          @body = json_response(env["PATH_INFO"])

          update_content_length
        end

        [status, @headers, @body]
      end

      private

        def matches_paths_to_include?(request_path)
          return true unless @options[:options].paths.any?

          @options[:options].paths.each do |path|
            next unless Middleman::Util.normalize_path(request_path) =~ %r[^#{path}]
            return true; break
          end
          return false
        end

        def json_response(request_path)
          resource = middleman_resource(request_path)
          metadata = resource.data.select do |k, v|
            !@options[:options].ignore_metadata_keys.include?(k)
          end

          locals = {
            title:    resource.data.title,
            metadata: metadata,
            path:     resource.url,
            content:  body.join
          }.with_indifferent_access

          [@options[:app].render_individual_file(json_template, locals: locals)]
        end

        def normalize_request_path(path)
          if @options[:app].extensions.include?(:directory_indexes)
            path += '/' unless path =~ /\/$/
            path += 'index.html'
          else
            path.chomp!('/')
            path += '.html'
          end
        end

        def middleman_resource(path)
          @options[:app].sitemap.find_resource_by_destination_path(path)
        end

        def json_template
          if @options[:options].template
            File.join(@options[:app].source_dir, @options[:options].template)
          else
            File.expand_path("../template.erb", __FILE__)
          end
        end

        def rewrite_content_type
          @headers["Content-Type"] = 'application/json'
        end

        def body
          @body.respond_to?(:body) ? @body.body : @body
        end

        def update_content_length
          @headers['Content-Length'] = Rack::Utils.bytesize(body.join).to_s
        end
    end
  end
end