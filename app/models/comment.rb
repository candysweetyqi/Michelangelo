class Comment < ActiveRecord::Base
  belongs_to :music
  belongs_to :user
 # has_many   :likes, as: :likeable, dependent: :destroy

  validates :content,      presence: true
  validates :post_id,      presence: true
  validates :user_id, presence: true


 

end
