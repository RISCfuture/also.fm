class Tag < ActiveRecord::Base
  belongs_to :playlist, inverse_of: :tags

  validates :playlist,
            presence: true
  validates :name,
            presence:   true,
            length:     {maximum: 50},
            uniqueness: {scope: :playlist_id},
            format:     {with: /\A[^,]+\z/}
end
