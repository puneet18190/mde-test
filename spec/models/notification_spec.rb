require 'spec_helper'

describe Notification do
  # USERS_AMOUNT           = 10_000
  # HUMANIZED_USERS_AMOUNT = ActionView::Base.new.number_to_human(USERS_AMOUNT)

  # describe '.send_to' do
  #   context "with #{HUMANIZED_USERS_AMOUNT} users" do
  #     let(:user_ids) do
  #       columns = %w( email name surname school_level_id encrypted_password confirmed active location_id created_at updated_at ).map{ |v| User.connection.quote_column_name(v) }
  #       school_level_id, location_id = SchoolLevel.first.id, School.first.id
  #       values_line = '( ' << ["%i@example.com", "%i", "%i", school_level_id, 'not_encrypted_password', true, true, location_id].map{ |v| User.connection.quote(v) }.push('NOW()', 'NOW()').join(', ') << ' )'
  #       values = USERS_AMOUNT.times.map{ |i| values_line % [i, i, i] }
  #       User.connection.execute("INSERT INTO #{User.quoted_table_name} (#{columns.join(', ')}) VALUES #{values.join(", ")} RETURNING id").values.flatten
  #     end
  #     let(:message) { 'ciao' }
  #     it 'works' do
  #       expect{ described_class.send_to(user_ids, message) }.to_not raise_error
  #     end
  #   end
  # end
end