class Playlist < ActiveRecord::Base
  belongs_to :for_user, class_name: 'User', inverse_of: :received_playlists
  belongs_to :from_user, class_name: 'User', inverse_of: :sent_playlists
  has_many :tags, dependent: :delete_all, inverse_of: :playlist

  accepts_nested_attributes_for :tags, reject_if: :all_blank

  validates :for_user,
            presence: true
  validates :url,
            presence:   true,
            url:        true,
            uniqueness: {scope: :for_user_id}
  validates :name,
            length:    {maximum: 100},
            allow_nil: true
  validates :description,
            length:    {maximum: 2000},
            allow_nil: true
  validates :priority,
            presence:     true,
            numericality: {greater_than_or_equal_to: 0}

  extend SetNilIfBlank
  set_nil_if_blank :name, :description

  attr_accessor :tag_names
  after_save :save_tags

  before_validation :set_name
  after_create :send_email

  def tag_names
    @tag_names ||= tags.map(&:name).join(', ')
  end

  private

  def save_tags
    tag_names.split(/\s*,\s*/).each do |name|
      tags.where(name: name).find_or_create
    end
  end

  def set_name
    self.name ||= url
  end

  def send_email
    PlaylistMailer.new_playlist(self).deliver_now
  end
end
