#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'net/http'
require 'open-uri'
require 'csv'
#require 'highline/import'

ag = Mechanize.new
#ag.keep_alive = false
# Need to set this or you get OpenSSL errors:
#ag.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
page = ag.get("http://portal.uspto.gov/external/portal/pair")
# We need the recaptcha URL which has the token we want - on the Public Pair page, this is the table
# class=epoTableBorder. The third tr has the recaptcha URL
rc_url = page.parser.xpath("//table[@class='epoTableBorder']/tr[3]/td[1]/script[2]/@src")
rc_code = page.parser.xpath("//table[@class='epoTableBorder']/tr[3]/td[1]/script[2]")
# If we download the code returned from visiting the recaptcha URL, then we can get the image token
# The image token can then be sent into the google recaptch API to return the challege image
rcpage = ag.get(rc_url)
# The rcpage.body will have a string of javascript. From this, we want the string that follows from "content : "
token = rcpage.body.partition("challenge : ")[2]
token = token.partition(",")[0]
# Now get rid of starting and ending quotes
token = token[1..(token.length-2)]
# Get the recaptcha image
#recaptcha_image = ag.get("http://www.google.com/recaptcha/api/image?c=" + token)
system("open", "http://www.google.com/recaptcha/api/image?c=#{token}")
form = page.forms.first
inputtext = ""
puts 'enter the challenge response'
inputtext = gets
form['recaptcha_response_field'] = inputtext
resp = form.submit
puts resp.body
# open browser with captcha image
#system("open", "http://www.google.com/recaptcha/api/image?c=" + token)
# enter captcha response in terminal
#captcha_says                             = ask("Enter Captcha from Browser Image:  ") { |q| q.echo = true }
#captcha_form["recaptcha_response_field"] = captcha_says
# submit captcha
#captcha_form.action                      = "http://www.google.com/recaptcha/api/noscript?#{params}"
#captcha_response                         = captcha_form.submit
# grab secret
#captcha_response                         = captcha_response.parser.css("textarea").first.text