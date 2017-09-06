require 'mkmf'

class PreChecks
  def PreChecks.checks
    v = find_executable 'cfssl'
    if v.match('no')
    puts "Warning... This requires CFSSL to be installed"
    exit 1
    end 
  end 
end
