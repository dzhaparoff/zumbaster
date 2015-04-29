class Crew < ActiveRecord::Base
  belongs_to :show
  belongs_to :person
end
