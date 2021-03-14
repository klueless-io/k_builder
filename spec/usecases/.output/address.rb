# frozen_string_literal: true

# Global Ruby Class Template
class Address
  attr_accessor :street1, :street2, :post_code, :state

  def initialize(street1, street2, post_code, state)
    @street1 = street1
    @street2 = street2
    @post_code = post_code
    @state = state
  end
end