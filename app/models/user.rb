require 'digest/sha2'

class User < ApplicationRecord
  SALT = '5d683ac93a'.freeze

  attr_accessor :password, :password_confirmation

  has_many :received_playlists, class_name: 'Playlist', foreign_key: 'for_user_id', dependent: :delete_all, inverse_of: :for_user
  has_many :sent_playlists, class_name: 'Playlist', foreign_key: 'from_user_id', dependent: :nullify, inverse_of: :from_user

  def self.reserved_names
    Rails.application.routes.routes.
        map { |r| r.path.spec.to_s.split('/')[1]&.sub(/\(.+$/, '') }.
        compact.uniq.reject { |p| p.start_with?(':') }
  end

  validates :username,
            presence:  true,
            length:    {maximum: 16},
            format:    {with: /\A[^$&+,\/:;=?@ "<>#%{}|\\\^~\[\]`]+\z/},
            exclusion: {in: reserved_names}
  validates :email,
            email:     true,
            allow_nil: true
  validates :password,
            confirmation: true,
            length:       {minimum: 6},
            exclusion:    {in: %w[123456 password 12345 12345678 qwerty 123456789 1234 baseball dragon football]},
            if:           :password
  validates :password, presence: {on: :create}

  before_validation :encrypt_password, if: :password

  extend SetNilIfBlank
  set_nil_if_blank :email

  def valid_password?(password)
    crypted_password == self.class.encrypt(password)
  end

  def to_param() username end

  # @private
  def self.encrypt(string)
    Digest::SHA256.hexdigest(string + SALT)
  end

  private

  def encrypt_password
    self.crypted_password = self.class.encrypt(password)
  end
end
