require 'fileutils'

class CleanUp
  def CleanUp.remove_files
    puts "Cleaning up files"
    FileUtils.rm Dir.glob('*.csr')
    FileUtils.rm Dir.glob('*.json')
    FileUtils.rm Dir.glob('*.pem')
    FileUtils.rm Dir.glob('*.log')
  end

  def CleanUp.clean_yaml
    puts "Cleaning up yaml"
    File.write("kubernetes.yaml",File.open("kubernetes.yaml",&:read).gsub(/^---$/,""))
  end
end
