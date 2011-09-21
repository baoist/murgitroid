class ApplicationController < ActionController::Base
  protect_from_forgery

  def files_from_dir(directory)
    files = Dir.glob(directory) # gets all files given a directory in /images/
    files.each_with_index do |file, index| files[index] = file.gsub('app/assets/images', '/assets') end
    return files
  end

  def page_images(url) # for maps and people on load
    pages = ["code", "decode", "about", "faqs", "terms", "contact"]
    maps = files_from_dir("app/assets/images/maps/*[.png|.jpg]")
    assoc = files_from_dir("app/assets/images/assoc/*[.png|.jpg]")

    pos = (pages.index(url).nil?)? 0 : pages.index(url)
    return [maps[pos], assoc[pos]]
  end

  def master_codes

  end

  def encode_message(master_key, a, b)
  end

  def decode_message(master_key, a, b)
  end
end
