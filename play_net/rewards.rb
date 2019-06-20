#!/usr/bin/env ruby
require "mechanize"
require_relative("./util/color.rb")

module Rewards
  OUTCOMES = {
    err:     {color: :red,   message: "✗ :error"},
    claimed: {color: :green, message: "✓ :claimed"},
    skip:    {color: :pink,  message: "✓ :skipped"},
  }

  def self.to_nokogiri(page)
    Nokogiri::HTML(page.content.toutf8)
  end

  def self.header()
    puts([ "outcome".rjust(10),
          "account".rjust(20),
          "balance".rjust(10),
          "\t" + "message"].join(" "))
  end

  def self.view(outcome:, account:, balance: "", message:)
    outcome = OUTCOMES.fetch(outcome)
    $stdout.puts(
      Color.send(outcome[:color], 
        [ outcome[:message].rjust(10),
          account.to_s.rjust(20),
          balance.to_s.rjust(10),
          "\t" + message.to_s].join(" ")))
  end

  def self.claim(account:, password:)
    @mechanize = Mechanize.new
    # random UA string so it's harder to discern we are botting
    @mechanize.agent.user_agent = Mechanize::AGENT_ALIASES.values.slice(1..-1).sample
    # sign in and redirect to the store front
    @mechanize.get("https://store.play.net/Account/SignIn?returnURL=%2Fstore%2Fpurchase%2Fgs") do |page|

      auth_result = page.form_with(method: 'POST') do |form|
        form["UserName"] = account
        form['Password'] = password
      end.submit

      auth_result_html = to_nokogiri(auth_result)
      auth_ok = auth_result.css("#login")
                  .text.strip.split("\n")
                  .first.downcase.start_with?(account.downcase)

      unless auth_ok
        return view(
          outcome: :err,
          account: account,
          message: "login did not succeed")
      end

      reward_state  = auth_result_html.css(".RewardMessage").text.downcase
      reward_amount = auth_result_html.css(".balance > span").text

      if reward_state.start_with?("next subscription bonus")
        return view(
          outcome: :skip,
          account: account,
          balance: reward_amount,
          message: reward_state)
      end
      
      reward_form = auth_result.form_with(action: "/Store/ClaimReward")
      
      if reward_form.nil?
        return view(
          outcome: :err,
          account: account,
          message: "no reward form found, maybe bad auth")
      end
        

      reward_form_result      = reward_form.submit 
      reward_form_result_html = to_nokogiri(reward_form_result)
      reward_amount           = reward_form_result_html.css(".balance > span").text
      redeemed_msg            = reward_form_result_html.css(".RewardMessage").text.downcase
      if redeemed_msg.start_with?("claimed")
        return view(
          outcome: :claimed,
          account: account,
          balance: reward_amount,
          message: redeemed_msg)
      end
    end
  end
end

