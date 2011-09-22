class ApplicationController < ActionController::Base
  protect_from_forgery

  def files_from_dir(directory)
    files = Dir.glob(directory) # gets all files given a directory in /images/
    files.each_with_index do |file, index| files[index] = file.gsub('app/assets/images', '/assets') end
    return files
  end

  def page_images(url) # for maps and people on load
    pages = ["code", "decode", "about", "faqs", "terms", "contact", "decoded"]
    maps = files_from_dir("app/assets/images/maps/*[.png|.jpg]")
    assoc = files_from_dir("app/assets/images/assoc/*[.png|.jpg]")

    pos = (pages.index(url).nil?)? 0 : pages.index(url)
    return [maps[pos], assoc[pos]]
  end

  def inner_codes 
    return [["D","7","R","4","9","L","K","Y","H","0","G","8","O","T","A","E","Z","W","3","X","2","Q","P","F","J","B","M","5","S","I","C","V","N","1","U","6"], ["H", "1", "L", "7", "O", "P", "D", "E", "4", "Q", "V", "Y", "F", "K", "X", "6", "Z", "3", "2", "U", "M", "B", "S", "5", "G", "R", "C", "9", "W", "8", "J", "I", "N", "0", "A", "T"], ["4", "J", "I", "0", "5", "2", "A", "Y", "B", "L", "N", "U", "F", "D", "V", "Q", "1", "P", "8", "Z", "3", "G", "E", "M", "H", "C", "7", "O", "T", "R", "6", "X", "9", "W", "S", "K"], ["J", "7", "I", "T", "E", "P", "U", "2", "V", "S", "K", "D", "W", "8", "1", "F", "L", "H", "Z", "5", "N", "R", "B", "9", "O", "C", "G", "6", "Y", "3", "Q", "A", "M", "X", "4", "0"], ["J", "P", "W", "2", "B", "Q", "R", "S", "X", "H", "G", "T", "N", "1", "I", "U", "Z", "9", "L", "M", "6", "5", "0", "4", "O", "K", "8", "F", "C", "Y", "7", "A", "E", "V", "D", "3"], ["S", "Q", "3", "I", "4", "D", "A", "W", "U", "6", "R", "O", "M", "E", "V", "J", "1", "2", "F", "L", "G", "7", "T", "Y", "P", "C", "H", "X", "B", "N", "9", "0", "K", "5", "Z", "8"], ["2", "W", "7", "D", "T", "X", "B", "P", "8", "E", "H", "Q", "A", "3", "K", "I", "Z", "1", "6", "4", "M", "L", "S", "N", "U", "J", "R", "Y", "0", "9", "C", "F", "G", "O", "5", "V"], ["K", "Y", "L", "G", "M", "7", "3", "8", "V", "T", "E", "R", "C", "W", "I", "1", "0", "P", "D", "2", "X", "Q", "J", "6", "A", "5", "O", "B", "Z", "H", "F", "S", "U", "4", "N", "9"], ["5", "1", "D", "E", "P", "7", "Y", "C", "6", "X", "U", "T", "8", "0", "W", "K", "R", "M", "9", "J", "V", "4", "L", "A", "O", "I", "N", "Q", "Z", "3", "F", "H", "S", "2", "B", "G"], ["2", "S", "T", "8", "L", "5", "W", "9", "Q", "H", "P", "A", "1", "F", "B", "I", "O", "N", "Z", "7", "U", "G", "E", "C", "6", "X", "0", "M", "V", "3", "R", "J", "Y", "K", "4", "D"]]
  end

  def master_code
    return ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
  end

  def encode_message(master_key, a, b, message)
    key = inner_codes()[master_key.to_i - 1]
    offset = master_code().index(a.to_s.capitalize) - key.index(b.to_s.capitalize)
    split_msg = message.split(//).delete_if { |l| l.match(/[^0-9A-Za-z]/) }

    split_msg.each_with_index do |letter, ind|
      position = key.index(letter.capitalize) + offset
      position = (position < 0)? 36 + position : position
      position = (position > 35)? -36 + position : position
      split_msg[ind] = master_code()[position]
    end
    return split_msg.join.scan(/.{5}|.+/).join(" ")
  end

  def decode_message(master_key, a, b, message)
    key = inner_codes()[master_key.to_i - 1]
    offset = master_code().index(a.to_s.capitalize) - key.index(b.to_s.capitalize)
    split_msg = message.split(//).delete_if { |l| l.match(/[^0-9A-Za-z]/) }

    split_msg.each_with_index do |letter, ind|
      position = master_code().index(letter.capitalize) - offset
      position = (position < 0)? 36 + position : position
      position = (position > 35)? -36 + position : position
      split_msg[ind] = key[position]
    end
    return split_msg.join.scan(/.{5}|.+/).join(" ")
  end
end
