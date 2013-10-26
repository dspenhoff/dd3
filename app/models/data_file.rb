class DataFile < ActiveRecord::Base
  # attr_accessible :title, :body
  def self.save(upload)
    name_path =  File.join('tmp', upload['datafile'].original_filename)
    File.open(name_path, "wb") { |f| f.write(upload['datafile'].read) }
    name_path
  end
end
