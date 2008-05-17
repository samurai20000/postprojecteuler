#!/usr/bin/env ruby

require 'rubygems'
require 'uri'
require 'mechanize'
require 'hpricot'
require 'logger'
require 'pp'
require 'pit'
require 'ostruct'

class PostProjectEuler
  VERSION = '0.0.1'

  class PostProjectEulerError < StandardError; end

  BASE = URI("http://projecteuler.net/")

  def initialize(config)
    @config = OpenStruct.new(config)
    @agent = WWW::Mechanize.new
  end

  def login
    login_page = @agent.get(BASE + '/index.php?section=login')
    login_form = login_page.forms.first
    login_form.username = @config.username
    login_form.password = @config.password
    result = @agent.submit(login_form, login_form.buttons.name('login'))
  end

  def post(question, answer)
    problem_page = @agent.get(BASE + "/index.php?section=problems&id=#{question}")
    answer_form = problem_page.forms.first
    answer_form.guess = answer
    result = @agent.submit(answer_form, answer_form.buttons.name(''))
    # answer_check(result)
  end

  private
  def answer_check(result)
    if result.body =~ /Sorry, but the answer you gave appears to be incorrect/ then
      puts $1
    elsif result.body =~ /hoge/ then
      puts $1
    end
  end
end

if __FILE__ == $0
  log = Logger.new(STDOUT)
  log.level = Logger::ERROR

  if ARGV.size == 2 then
    post_ppe = PostProjectEuler.new('userid', 'password')
    post_ppe.login
    post_ppe.post(ARGV[1], ARGV[2])
  else
    p ARGV[2]
    log.error('error');
  end
end
