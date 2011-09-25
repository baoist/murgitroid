class AddCaptchaToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :captcha, :string
  end
end
