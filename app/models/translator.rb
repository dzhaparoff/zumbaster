class Translator < ActiveRecord::Base
  has_many :translations

  class << self
    def sync
      moonwalk = Moonwalk.new
      translators = moonwalk.translators
      translators.each do |translator|
        if Translator.find_by_ex_id(translator['id']).nil?
          new_translator = Translator.new do |t|
            t.ex_id = translator['id']
            t.name = translator['name']
          end
          new_translator.save
        end
      end
      translators
    end
  end
end
