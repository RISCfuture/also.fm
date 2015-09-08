json.name playlist.name
json.url playlist.url

json.read_only? read_only
json.listened? playlist.listened_at?
json.description? playlist.description?
json.formatted_description simple_format(playlist.description)

unless read_only
  json.from_user? !playlist.from_user.nil?
  json.from_user do
    json.url new_playlist_url(playlist.from_user)
    json.username playlist.from_user.username
  end if playlist.from_user
end

json.tags? playlist.tags.any?
json.tags do
  json.array!(playlist.tags) do |tag|
    if read_only
      json.filter_url playlist_url(playlist.for_user, tag: tag.name)
    else
      json.filter_url root_url(tag: tag.name)
    end
    json.name tag.name
    json.last?(tag == playlist.tags.last)
  end
end

json.ack_url ack_account_playlist_url(playlist, format: 'json')
