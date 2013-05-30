require "open-uri"

DATA_URL = "http://110.75.21.155/data/tmpdata/?f=file&folder=log_for_jstracker"

class ParserController < ApplicationController

  def initialize
    @D = {}
  end

  def getHost(url)
    begin
      URI.parse(url.gsub(/\s/, "")).host
    rescue Exception => e
      ""
    end
  end

  def getMsg(gokey)
    querystring = CGI.parse URI.decode(gokey)
    querystring["msg"][0]
  end

  def getBrowser(ua)
    if ua && ua.length < 50 && ua.index(",")
      ua.split(",")[0]
    else
      "other"
    end
  end

  def fetchData
    data = URI.parse(DATA_URL).read.split "\n"
    p "get data size: #{data.count}"
    data.each do |item|
      next if !item
      item, ip, gokey, cna, uid, sid, url, useragent = item.split "\""
      host    = getHost(url)
      next if !host || host.size < 5
      msg     = getMsg(gokey)
      next if !msg || msg.size > 200
      browser = getBrowser(useragent)

      # Add item to D cache.
      @D[host] ||= {}
      @D[host][msg] ||= {
        "msg" => msg,
        "count" => 0,
        "browsers" => {}
      }
      @D[host][msg]["count"] += 1
      @D[host][msg]["browsers"][browser] ||= {"count"=>0}
      @D[host][msg]["browsers"][browser]["count"] += 1
    end
    # p @D
  end

  def save
    p "saving"
    @D.each do |host, val|
      host_id = addHost(host)[:id]
      # p host_id
      val.each do |msg, item|
        msg_id = addMsg(msg, host_id, item["count"])[:id]
        addDailyCount(msg_id, item["count"])
        item["browsers"].each do |browser, item|
          addBrowserCount(msg_id, browser, item["count"])
        end
      end
    end
    @D = {}
  end

  def addHost(host)
    h = Host.find(:first, :conditions=>{:name=>host})
    h || Host.create(:name => host)
  end

  def addMsg(msg, host_id, count)
    m = Msg.find(:first, :conditions=>{:msg=>msg,:host_id=>host_id})
    if m
      # tmp = m[:count]
      m[:count] += count
      m.save
      # p "#{tmp} + #{count} = #{m[:count]}"
      m
    else
      Msg.create(:host_id=>host_id,:msg=>msg,:count=>count,:type_id=>1)
    end
  end

  def addDailyCount(msg_id, count)
    date = Date.today
    d = DailyCount.find(:first, :conditions=>{:msg_id=>msg_id,:date=>date})
    if d
      d[:count] += count
      hc = d[:hourlycount].split(",")
      hour = DateTime.now.hour
      hc[hour] = hc[hour].to_i + count
      d[:hourlycount] = hc.join(",")
      d.save
      d
    else
      hc = Array.new(24, 0)
      hour = DateTime.now.hour
      hc[hour] = hc[hour].to_i + count
      hc = hc.join(",")
      DailyCount.create(:msg_id=>msg_id,:count=>count,:date=>date,:hourlycount=>hc)
    end
  end

  def addBrowserCount(msg_id, browser, count)
    date = Date.today
    b = BrowserCount.find(:first, :conditions=>{:browser=>browser,:msg_id=>msg_id,:date=>date})
    if b
      b[:count] += count
      b.save
      b
    else
      BrowserCount.create(:msg_id=>msg_id,:count=>count,:date=>date,:browser=>browser)
    end
  end

end
