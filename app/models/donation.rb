class Donation < ApplicationRecord
  class << self
    def sync
      params = {}
      last_donation = self.first
      if last_donation.present?
        params[:after] = last_donation.ex_id
      end
      donations = api :transactions, params

      if donations['status'] === 'success' &&  donations['count'] > 0
        donations['data'].each do |donation|
          self.where(ex_id: donation['id']).first_or_create do |new_donation|
            new_donation.ex_id = donation['id']
            new_donation.name = donation['vars']['name']

            new_donation.amount = donation['sum']
            new_donation.amount_payed = donation['to_pay']
            new_donation.amount_cash = donation['to_cash']

            new_donation.payment_system = donation['vars']['payment_system']
            new_donation.comment = donation['vars']['comment']
            new_donation.donation_date = Time.parse(donation['created_at']['date'])
          end
        end
      end
    end

    def current_month
      self.select(:amount_cash).where(donation_date: [Time.now.at_beginning_of_month..Time.now]).inject(0) do |sum, donation|
        sum + donation.amount_cash
      end
    end

    def prev_month
      self.select(:amount_cash).where(donation_date: [Time.now.at_beginning_of_month.prev_month...Time.now.at_beginning_of_month]).inject(0) do |sum, donation|
        sum + donation.amount_cash
      end
    end

    def current_month_progress amount_needed = 18_000
      (self.current_month / amount_needed * 100).round(2)
    end

    private
    def api method, options = {}
      response = conn.get("/api/v1/#{method}") do |request|
        request.params.merge! options
      end
      Oj.load(response.body,{})
    end

    def conn
      Faraday.new url:'http://donatepay.ru' do |client|
        client.params['access_token'] = 'wE7Nu73sYiopVggxG3eHenqofgU5rdHwX0vMW9N197k2dJQlc0AnYBWe0X4O'
        client.params['type'] = 'donation'
        client.params['status'] = 'success'
        client.params['limit'] = '100'
        client.adapter  Faraday.default_adapter
        client.request  :url_encoded
        client.response :logger
      end
    end
  end
end
