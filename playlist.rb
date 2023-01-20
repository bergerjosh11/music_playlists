require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'json'
  gem 'net-http'
end

require 'json'
require 'net-http'

class Playlist
  def base_file
    url = "https://gist.githubusercontent.com/vitchell/fe0b1cb51e158058fb1b9d827584d01f/raw/f00f4d94d9d87b0d928bb3766a2667fb502d7407/spotify.json"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def change_list_file
    url = "https://github.com/bergerjosh11/test_file/blob/main/playlist_changes.json"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def output_file
    File.new
  end

  def intake(base_file, change_list_file, output_file)
    output_file.write(JSON(update_playlist(base_file, change_list_file)))
  end

  private

  def update_playlist(music_player, updates)
    updates['add_new_songs'].each do |x|
      music_player['playlists'].select { |y| y['id'] == x['playlist_id'] }.first['song_ids'].push(x['song_id'])
    end
    playlist_ids = music_player['playlists'].map { |x| x["id"].to_i }.sort_by(&:id)
    updates['add_playlists'].each do |y|
      music_player['playlists'].push({id: playlist_ids.push(playlist_ids.last + 1).to_s, owner_id: y['owner_id'], song_ids: y['song_id']})
    end
    changes['remove_playlists'].each do |x|
      music_player['playlists'] = music_player['playlists'].reject{|y| y['id'] == x}
    end
  end
end

Playlist.new
