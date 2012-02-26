#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'net/http'
require 'open-uri'

ag = Mechanize.new
baseurl = "http://appft1.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-adv.html&r=0&f=S&l=50&d=PG01&"
# This will search for apps published on 2/23/2012 (patent apps are published every Wednesday)
dateq = "Query=PD%2F2%2F23%2F2012"
page = ag.get(baseurl + dateq)
