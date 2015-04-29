class Translation < ActiveRecord::Base
  belongs_to :episode
  belongs_to :translator
end
