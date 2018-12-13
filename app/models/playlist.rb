class Playlist < ApplicationRecord
  belongs_to :for_user, class_name: 'User', inverse_of: :received_playlists
  belongs_to :from_user, class_name: 'User', inverse_of: :sent_playlists, optional: true
  has_many :tags, dependent: :delete_all, inverse_of: :playlist

  accepts_nested_attributes_for :tags, reject_if: :all_blank

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

  attr_writer :tag_names
  after_save :save_tags

  before_validation { |u| u.url = u.url&.strip }
  before_validation :set_name
  after_create :send_email

  def tag_names(reload: false)
    @tag_names = nil if reload
    @tag_names ||= tags.order('id ASC').map { |t| "##{t.name}" }.join(' ')
  end

  private

  def save_tags
    new_tags = tag_names.scan(/#(\w+)/).flatten
    new_tags.each do |name|
      tags.where(name: name).find_or_create
    end
    tags.where('name NOT IN (?)', new_tags).delete_all
  end

  def set_name
    self.name ||= url
  end

  def send_email
    PlaylistMailer.new_playlist(self).deliver_now
  end
end
