# encoding: utf-8

namespace :jstracker do

  desc "Parse data"
  task parse: :environment do
    pc = ParserController.new
    count = 0
    while true
      sleep(1)
      begin
        pc.fetchData()
        count = count + 1
        pc.save() if count % 20 == 0
      rescue Exception => e
        p e
      end
    end
  end

  desc "Delete all date"
  task clean: :environment do
    Msg.delete_all
  end

  desc "Test something"
  task test: :environment do
    # Do
  end

end
