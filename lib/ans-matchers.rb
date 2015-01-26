require "ans-matchers/version"

require "rspec/expectations"

module Ans
  module Matchers
    include ActiveSupport::Configurable
  end
end

require "ans-matchers/success_persistance_of"
require "ans-matchers/have_executable_scope"
require "ans-matchers/have_out_of_range_validation"
require "ans-matchers/have_association_db_index"
