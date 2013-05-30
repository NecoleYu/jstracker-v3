
require "time_diff"

class MsgsController < ApplicationController
  
  include ActionView::Helpers::DateHelper

  def index
    @msgs = Msg.all
    render json:@msgs
  end

  def show
    @msg = Msg.find(params[:id])
    msg = {
      :id => @msg["id"],
      :host_id => @msg["host_id"],
      :type_id => @msg["type_id"],
      :msg => @msg["msg"],
      :count => @msg["count"],
      :created_at => distance_of_time_in_words_to_now(@msg["created_at"]) + " ago",
      :updated_at => distance_of_time_in_words_to_now(@msg["updated_at"]) + " ago",
      :daily_counts => [],
      :browser_counts => []
    }

    (0..15).each do |num|
      # num = 6 - num
      if num > 1
        key = "#{num} days ago"
      elsif num == 1
        key = "yestoday"
      else
        key = "today"
      end
      msg[:daily_counts].push [key, 0]
    end

    dc_data = @msg.daily_counts.where("date > ?", 15.days.ago)
    dc_data.each do |item|
      index = Time.diff(item["date"], Date.today)[:day]
      msg[:daily_counts][index][1] = item["count"]
    end
    msg[:daily_counts].reverse!
    msg[:hourly_counts] = dc_data.last["hourlycount"]

    bc = {}
    @msg.browser_counts.where("date > ?", 7.days.ago).each do |item|
      bc[item["browser"]] ||= 0
      bc[item["browser"]] += item["count"]
    end
    bc.each do |k, v|
      msg[:browser_counts].push([k, v])
    end

    # Host.find
    render json:msg
  end

  def changetype
    msg = Msg.find(params[:id])
    type_id = params[:type_id]
    result = {:status => "1"}
    if type_id && Type.find(type_id)
      msg.type_id = type_id
      result[:status] = msg.save ? "1" : "0"
    else
      result[:status] = "0"
    end
    render json:result
  end
end
