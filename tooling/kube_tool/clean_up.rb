require 'fileutils'

class CleanUp
  def CleanUp.remove_files
    puts "Cleaning up files"
    FileUtils.rm Dir.glob('*.csr')
    FileUtils.rm Dir.glob('*.json')
    FileUtils.rm Dir.glob('*.pem')
    FileUtils.rm Dir.glob('*.log')
  end
end
