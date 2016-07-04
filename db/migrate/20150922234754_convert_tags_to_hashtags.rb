class ConvertTagsToHashtags < ActiveRecord::Migration[4.2]
  def up
    Tag.find_each do |tag|
      tag.name.scan(/#(\w+)/).each do |hashtag|
        Tag.create! playlist_id: tag.playlist_id, name: hashtag.first
      end
      tag.destroy if tag.name.include?('#')
    end
  end

  def down
    # nothing to do
  end
end
