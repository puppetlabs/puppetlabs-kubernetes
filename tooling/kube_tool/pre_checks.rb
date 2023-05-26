# frozen_string_literal: true

require 'English'

# Pre Checks
class PreChecks
  def self.checks
    system('which cfssl')
    x = $CHILD_STATUS.success?
    return unless x == false

    puts 'Warning... This requires CFSSL to be installed'
    puts 'Please follow the instructions here https://github.com/cloudflare/cfssl'
    puts 'Make sure the CFSSL binary is in your $PATH'
    exit 1
  end
end
