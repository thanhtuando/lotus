require 'lotus/generators/abstract'
require 'lotus/utils/string'

module Lotus
  module Generators
    class Action < Abstract
      ACTION_SEPARATOR = /\/|\#/
      SUFFIX           = '.rb'.freeze
      TEMPLATE_SUFFIX  = '.html.'.freeze
      DEFAULT_TEMPLATE = 'erb'.freeze

      def initialize(command)
        super

        @controller, @action = name.split(ACTION_SEPARATOR)
        @controller_name     = Utils::String.new(@controller).classify
        @action_name         = Utils::String.new(@action).classify

        cli.class.source_root(source)
      end

      def start
        opts = {
          app:        app,
          controller: @controller_name,
          action:     @action_name
        }

        templates = {
          'action.rb.tt' => _action_path,
          'view.rb.tt'   => _view_path,
          'template.tt'  => _template_path
        }

        case options[:test]
        when 'rspec'
        else
          templates.merge!({
            'action_spec.minitest.tt' => _action_spec_path
          })
        end

        ##
        # New files
        #
        templates.each do |src, dst|
          cli.template(source.join(src), target.join(dst), opts)
        end
      end

      private
      def _action_path
        "#{ Pathname.new(app_root).join('controllers', @controller, @action) }#{ SUFFIX }"
      end

      def _view_path
        "#{ Pathname.new(app_root).join('views', @controller, @action) }#{ SUFFIX }"
      end

      def _template_path
        "#{ Pathname.new(app_root).join('templates', @controller, @action) }#{ TEMPLATE_SUFFIX }#{ options.fetch(:template) { DEFAULT_TEMPLATE }}"
      end

      def _action_spec_path
        "#{ Pathname.new('spec').join(app_name, 'controllers', @controller, "#{ @action }_spec") }#{ SUFFIX }"
      end
    end
  end
end
