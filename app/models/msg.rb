class Msg < ActiveRecord::Base
  belongs_to :host
  has_many :daily_counts
  has_many :browser_counts
end
