class Code < ActiveRecord::Base
=begin
  def message_coded
    puts encode_message(self[:master], self[:key_a], self[:key_b], self[:message]) , "foobar"
    self.message_coded = encode_message(self[:master], self[:key_a], self[:key_b], self[:message])
  end

  def ip
    write_attribute(:ip, "foo")
  end
=end
end
