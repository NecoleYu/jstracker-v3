
require "time_diff"

BROWSERS = ["msie", "chrome", "firefox", "safari", "opera"]

class HostsController < ApplicationController
  
  include ActionView::Helpers::DateHelper

  def index
    hosts = []
    Host.all.each do |host|
      hosts.push({
        :id => host["id"],
        :name => host["name"]
      })
    end
    render json:hosts
  end

  def show
    sort = (params["updated_at"] == "count" || !params["updated_at"]) ? "count" : "updated_at"

    type_id = params["type_id"]
    sql_append = ""
    # if type_id
    #   sql_append = "AND msgs.type_id = #{type_id}"
    # end

    host = Host.find(params[:id])
    msgs = host.msgs
      .select("msgs.id as msg_id, msgs.msg, msgs.count, msgs.type_id, msgs.created_at, msgs.updated_at, daily_counts.id, daily_counts.count as daily_count, daily_counts.date as daily_date")
      .joins("RIGHT JOIN `daily_counts` ON daily_counts.msg_id = msgs.id #{sql_append}")
      .where("msgs.count > ?", 100)
      .where("daily_counts.date > ?", 7.days.ago)
      .order("msgs.#{sort} DESC")

    data = {}
    msgs.each do |item|
      msg_id = item["msg_id"]
      data[msg_id] ||= {
        :msg => item["msg"],
        :count => item["count"],
        :type_id => item["type_id"],
        :created_at => distance_of_time_in_words_to_now(item["created_at"]) + " ago",
        :updated_at => distance_of_time_in_words_to_now(item["updated_at"]) + " ago",
        :daily_counts => [0,0,0,0,0,0,0],
        :weekly_total => 0,
        :browser_counts => {},
        :browsers => []
      }
      index = 6 - Time.diff(item["daily_date"], Date.today)[:day]
      if index >=0 && index <= 6
        data[msg_id][:daily_counts][index] = item["daily_count"]
      end
    end

    msgs = host.msgs
      .select("msgs.id as msg_id, browser_counts.id, browser_counts.msg_id, browser_counts.browser, browser_counts.count, browser_counts.date")
      .joins("RIGHT JOIN `browser_counts` ON browser_counts.msg_id = msgs.id")
      .where("browser_counts.date > ?", 7.days.ago)

    msgs.each do |item|
      msg_id = item["msg_id"]
      next if !data[msg_id]
      data[msg_id][:weekly_total] = data[msg_id][:daily_counts].inject{ |sum,x| sum+x }
      if data[msg_id][:browser_counts]
        data[msg_id][:browser_counts][item["browser"]] ||= {}
        data[msg_id][:browser_counts][item["browser"]][item["date"]] = item["count"]
        browser = item["browser"].gsub(/\d+/, "").gsub("_low", "")
        if BROWSERS.index(browser) != nil && data[msg_id][:browsers].index(browser) == nil
          data[msg_id][:browsers].push(browser)
        end
      end
    end

    # Filter browser.
    browser = params[:browser]
    if browser && browser != "all"
      data.each do |key, val|
        is_delete = true
        val[:browser_counts].each do |bkey, bval|
          if (bkey.index(browser) != nil)
            is_delete = false
          end
        end
        if is_delete
          data.delete(key)
        end
      end
    end

    types = {
      :all     => data.count,
      :open    => 0,
      :closed  => 0,
      :ignored => 0
    }
    data.each do |key, val|
      if val[:type_id] == 2
        types[:closed] += 1
      elsif val[:type_id] == 3
        types[:ignored] += 1
      else
        types[:open] += 1
      end
      if val[:type_id] != type_id.to_i
        data.delete key
      end
    end

    o = {}
    o["id"]   = host.id
    o["name"] = host.name
    o["msgs"] = data
    o["types"] = types
    render json:o
  end
end
