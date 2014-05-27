#!/usr/bin/env ruby
# encoding: utf-8
require 'json'
require 'net/http'
require 'mail'
require 'nokogiri'
require 'net/imap'
require 'logger'

## Usage
# ruby collector/collector.rb staging|prod|local [mark]
# if it contains the parameter "mark", the message will be mark as "read"
#

# TODO setup portal config
case ARGV[0]
when "staging"
  WF_PORTAL_HOST = "woodenfish.staging.unknown.com"
  WF_PORTAL_PORT = 80
  MAIL_SEARCH_KEYS = "UNSEEN OR TO woodenfish-staging CC woodenfish-staging"
when "prod"
  # prod
  WF_PORTAL_HOST = "woodenfish.prod.unknown.com"
  WF_PORTAL_PORT = 80
  MAIL_SEARCH_KEYS = "UNSEEN OR TO woodenfish CC woodenfish NOT OR TO woodenfish-staging CC woodenfish-staging"
else
  # local
  WF_PORTAL_HOST = "localhost"
  WF_PORTAL_PORT = 3000
  MAIL_SEARCH_KEYS = "UNSEEN OR TO woodenfish-staging CC woodenfish-staging"
end

MARK_MAIL = (ARGV[0] == 'prod' || ARGV[1] == 'mark')
$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

Mail.defaults do
  retriever_method :imap, :address    => "exg5.exghost.com",
                          :port       => 993,
                          :user_name  => 'wooden-fish-bot@unknown.com',
                          :password   => 'SECRET',
                          :enable_ssl => true
end

# TODO:
# the find should be recursive, and should always be ordered by time
# may probably introduce a "sync" point in the database, but not sure if
# this is doable by IMAP or POP3
def feed_latest_mails
  Mail.find(:what => :last, :count => 30, :keys => MAIL_SEARCH_KEYS, :order => :asc) do |mail, imap, uid|
    if MARK_MAIL
      imap.uid_store(uid, "+FLAGS", [Net::IMAP::SEEN])
    else
      imap.uid_store(uid, "-FLAGS", [Net::IMAP::SEEN])
    end
    $logger.debug "-----------------"
    $logger.debug "subject: #{mail.subject}"
    $logger.debug "from   : #{mail.from}"
    $logger.debug "to     : #{mail.to}"
    $logger.debug "cc     : #{mail.cc}"
    $logger.debug "id     : #{mail.message_id}"
    $logger.debug "date   : #{mail.date}"
    $logger.debug "charset: #{mail.charset}"
    feed_to_wf_portal(mail)
    $logger.debug "-----------------"
  end
end


def get_body(mail)
  #puts "bodyraw: #{mail.body.decoded}"
  if mail.multipart? && !mail.html_part.nil?
    mail = mail.html_part
  end
  body = mail.body.decoded.force_encoding(mail.charset).encode("UTF-8")
  document = Nokogiri::HTML.parse(body)
  html_body = clean_html_body(document)
  document.css("div,p").each { |node| node << "<br />" }
  document.css("br").each { |node| node.replace("\r\n") }
  [document.text, html_body]
end

def feed_to_wf_portal(mail)
  from = mail.from[0].to_s
  user = {
    "name" => get_name_from_email(from),
    "email" => from
  }

  body_text, body_html = get_body(mail)

  detail = {
    "subject" => mail.subject.to_s,
    "body" => body_text,
    "created" => mail.date.to_time.to_i,
    "source" => "email",
    "source_id" => mail.message_id.to_s
  }

  params = {}
  if is_comment?(mail)
    detail["commentable_source_id"] = mail.header["In-Reply-To"].message_ids.first rescue mail.header["In-Reply-To"].value
    original_body = detail["body"]
    detail["body"] = clean_comment_body(body_html, original_body)
    detail["original_body"] = body_html.length != 0 ? body_html : original_body
    if do_create(user, detail, "comment") == "null"
      detail["body"] = original_body
      do_create(user, detail, "post")
    end
  else
    do_create(user, detail, "post")
  end
end

def do_create(user, detail, type)
  params = {user: user}
  if type == "comment"
    endpoint = "/comments"
    params["comment"] = detail
  else
    endpoint = "/posts"
    params["post"] = detail
  end
  params["without_login"] = "true"
  $logger.debug "  post: #{params}"
  http = Net::HTTP.new(WF_PORTAL_HOST, WF_PORTAL_PORT)
  response = http.post(endpoint, params.to_json, {"Content-Type" => "application/json"})
  $logger.debug "resp code: #{response.code}"
  $logger.debug "resp body: #{response.body}"
  response.body
end

def clean_html_body(document)
  document.css("body")[0].to_s.strip.sub(/^\<body\s*\>/i, "").sub(/\<\/body\s*\>/i, "")
end

def clean_comment_body(body_html, body)
  comment_text = nil
  if body_html.length != 0
    document = Nokogiri::HTML.parse(body_html)
    gmail_extra = document.css("//body/div.gmail_extra")
    olk_src_body = document.css("//body/#OLK_SRC_BODY_SECTION")
    if gmail_extra.length > 0
      gmail_extra.remove
      comment_text = clean_html_body(document)
    elsif olk_src_body.length > 0
      olk_src_body.remove
      comment_text = clean_html_body(document)
    end
  end
  comment_text = body.sub(/((On\s(.+)wrote:).*)|((在\s*(.+)写道).*)$/m, "").strip if comment_text.nil?
  $logger.info(comment_text)
  $logger.info("--------------")
  comment_text
end

# TODO CJ: improve this, should check if the "In-Reply-To" existed in wf or not
def is_comment?(mail)
  !mail.header["In-Reply-To"].nil?
end

def get_name_from_email(email_address)
  email_address[0..(email_address.index("@") - 1)].sub('.', ' ').split.map(&:capitalize).join(' ').capitalize
end

def main
  feed_latest_mails
end

main
