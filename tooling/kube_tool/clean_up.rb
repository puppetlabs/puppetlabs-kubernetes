require 'fileutils'

class CleanUp
  def self.all(files)
    files.each do |x|
      if File.exist?(x)
        FileUtils.rm_f(x)
      end
    end
  end

  def self.remove_files
    puts "Cleaning up files"
    FileUtils.rm Dir.glob('*.csr')
    FileUtils.rm Dir.glob('*.json')
    FileUtils.rm Dir.glob('*.pem')
    FileUtils.rm Dir.glob('*.log')
    FileUtils.rm('discovery_token_hash')
  end

  def self.clean_yaml(os)
    os = os.capitalize
    puts "Cleaning up yaml"
    File.write("kubernetes.yaml",File.open("kubernetes.yaml",&:read).gsub(/^---$/,""))
    File.write("kubernetes.yaml",File.open("kubernetes.yaml",&:read).gsub("'",""))
    FileUtils.mv("kubernetes.yaml","#{os}.yaml")
  end

end
