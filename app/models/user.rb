class User < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_secure_password

  has_many :friendships
  has_many :users, through: :friendships
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_attached_file :image, :styles => { :small => "150x150" }
                    # #for production uploads
                    # :storage=> :s3,
                    # :s3_credentials => "#{Rails.root}/config/aws.yml",
                    # :path => "/profile/:id/:style:extension"
                    
                    # #for development uploads:
                    # :url => "/assets/users/:id/:style/:basename.:extension",
                    # :path => ":rails_root/public/assets/users/:id/:style/:basename.:extension"

  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']


  after_destroy :ensure_an_admin_remains
  

  def friends
    friender_friends_ids = "SELECT friender_id FROM friendships
                            WHERE friended_id = :user_id AND accepted = 1"
    friended_friends_ids = "SELECT friended_id FROM friendships
                            WHERE friender_id = :user_id AND accepted = 1"

    User.where("id IN (#{friender_friends_ids}) OR
          id IN (#{friended_friends_ids})", user_id: self.id)
    
    # User.where("id IN (#{friended_friends_ids})",user_id: self.id)
       
  end

  # Only display the sharing contents of the user and his friends
  def discover_musics
    valid_ids = self.friends.map {|friend| friend.id}
    valid_ids.push(self.id)
    Music.where(:uid => valid_ids).order("created_at DESC")
  end

  def requests_from
    # frienders_ids = "SELECT friender_id FROM friendships 
    #                  WHERE friended_id = :user_id AND accepted = false"
    frienders_ids = "SELECT friender_id FROM friendships 
                     WHERE friended_id = :user_id AND accepted = 0"

    User.where("id IN (#{frienders_ids})", user_id: self.id)
  end

  def friend_request(friended)
    friender_id = self.id 
    # friended_id = params[:id] # this is the id of the user you want to become friend with
    friendship = Friendship.create(friender_id: friender_id, friended_id: friended.id, accepted: 0)
  end

  def check_friendship(friend_id)
    result1 = Friendship.where(friender_id: self.id, friended_id: friend_id, accepted: 1 ) 
    result2 = Friendship.where(friender_id: friend_id, friended_id: self.id, accepted: 1 )
    (result1.any? || result2.any?)
  end

def friend_request_accept(friender)
  # accepting a friend request is done by the recipient of the friend request.
  # thus the current user is identified by friended_id.
  friendship = Friendship.where(friended_id: self.id,  friender_id: friender.id).first
  friendship.update_attributes(accepted: 1)
end

def friend_request_reject(friender)
  friendship = Friendship.where(friended_id: self.id,  friender_id: friender.id).first
  friendship.destroy
end


  private
    def ensure_an_admin_remains
      if User.count.zero?
        raise "Can't delete last user"
      end
    end     
end
