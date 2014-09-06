module Markdownable
  extend ActiveSupport::Concern

  module ClassMethods
    def markdownable(*fields)
      fields.each do |field|
        define_method "#{field}_html" do
          Markdownable.markdown(self.send(field))
        end
        define_method "#{field}_toc" do
          Markdownable.markdown_toc(self.send(field))
        end
      end
    end
  end

  class ArticlesRenderer < Redcarpet::Render::HTML
    def initialize(extensions = {})
      super extensions.merge(with_toc_data: true, link_attributes: { target: "_blank" })
    end

    def block_code(code, language)
      language, filename = language.split ':'
      filename(filename) + CodeRay.scan(code, language).div()
    end

    def paragraph(text)
      text.gsub(/\n/, "<br>\n")
    end

  private

    def filename(filename)
      return "" if filename.blank?
      %!<div class="code-filename">#{filename}</div>!
    end
  end

  NO_TOC_TEXT = "--no-toc"

  def self.markdown(text)
    Redcarpet::Markdown.new(
        ArticlesRenderer.new(),
        autolink: true,
        space_after_headers: false,
        fenced_code_blocks: true,
        tables: true,
        strikethrough: true,
        superscript: true)
      .render(text.sub(NO_TOC_TEXT, ''))
  end

  def self.markdown_toc(text)
    return "" if text.match(/^#{NO_TOC_TEXT}/)
    Redcarpet::Markdown.new(
        Redcarpet::Render::HTML_TOC,
        fenced_code_blocks: true)
      .render(text)
      .tap {|toc|
        break "<h1>#{I18n.t('articles.index_title')}</h1> #{toc}<hr>" unless toc.blank?
      }
  end

end
