require 'fileutils'

class CleanUp
  def CleanUp.remove_files
    puts "Cleaning up files"
    FileUtils.rm Dir.glob('*.csr')
    FileUtils.rm Dir.glob('*.json')
    FileUtils.rm Dir.glob('*.pem')
    FileUtils.rm Dir.glob('*.log')
    FileUtils.rm('discovery_token_hash')
  end

  def CleanUp.clean_yaml(os)
    os = os.capitalize
    puts "Cleaning up yaml"
    File.write("kubernetes.yaml",File.open("kubernetes.yaml",&:read).gsub(/^---$/,""))
    File.write("kubernetes.yaml",File.open("kubernetes.yaml",&:read).gsub("'",""))
    FileUtils.mv("kubernetes.yaml","#{os}.yaml")
  end

end
