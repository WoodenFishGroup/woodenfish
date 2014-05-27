require 'active_support/all'
require 'digest/md5'
require 'redcarpet'

module ApplicationHelper
  def get_timezone_offset(zone)
    return 0 if zone.nil?
    if zone.downcase == 'cst'
      8.hours
    elsif zone.downcase == 'pst'
      -7.hours
    end
  end

  def is_mail_safe_image?(url)
    url.include?("http://www.gravatar.com/avatar/")
  end

  def get_current_user_name
    current_user.nil? ? "unknown" : current_user.name
  end

  def get_current_user_email
    current_user.nil? ? nil : current_user.email
  end

  def get_current_user_id
    current_user.nil? ? nil : current_user.id
  end

  def get_current_user_avartar
    current_user.nil? ? "http://www.gravatar.com/avatar/a" : current_user.avartar
  end

  def get_default_gravartar(email)
    hash = Digest::MD5.hexdigest(email.downcase)    
    "http://www.gravatar.com/avatar/#{hash}?d=identicon"
  end

  # create a custom renderer that allows highlighting of code blocks
  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
       Pygments.highlight(code, lexer: language)
    end
  end
  
  def render_text_to_html(raw_text)
    markdown = Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true, autolink: true)
    marker = "!m"
    if raw_text.include? marker
      # render as Markdown IF contains marker
      return markdown.render(raw_text.sub(marker, ''))
    else
      # render as plain text Otherwise
      return auto_link(simple_format(raw_text))
    end
  end

  def info_has_all_values?(info, keys)
    (info.values_at(*keys).index {|v| v.nil? || v == ""}).nil?
  end
end
