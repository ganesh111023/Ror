# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module RenderTreeHelper
  class Render
    class << self
      attr_accessor :h, :options

      def render_node(h, options)
        @h, @options = h, options

        node = options[:node]
        "
          <li>
              #{ show_link }
              #{ children }
          </li>
        "
      end

      def show_link
        node = options[:node]
        ns   = options[:namespace]
        url  = h.url_for(ns + [node])
        title_field = options[:title]
        str = '<span class="fa arrow"></span>'
        unless options[:children].blank?
          "#{ h.link_to((node.send(title_field) + str).html_safe, url) }"
        else
          "#{ h.link_to(node.send(title_field), url) }"
        end
      end

      def children
        unless options[:children].blank?
          "<ul class='nav depth_#{options[:node].depth}'>#{ options[:children] }</ul>"
        end
      end

    end
  end
end