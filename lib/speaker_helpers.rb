require 'httparty'
require 'ostruct'

module SpeakerHelpers
  def all_speakers
    data.speakers
      .collect { |name, speaker_data| Speaker.new(name, speaker_data) }
      .sort_by { |speaker| speaker.name }
  end

  private

  class Speaker
    attr_reader :name
    attr_reader :profile
    attr_reader :talks

    delegate :github_username,
      :twitter_username,
      :avatar_url,
      :bio,
      :blog, to: :profile

    def initialize(name, speaker_data)
      @name = name
      @talks = speaker_data[:talks]
      
      if speaker_data[:profile][:github_username].present?
        @profile = OpenStruct.new github_profile(speaker_data[:profile][:github_username])
      else
        @profile = OpenStruct.new speaker_data[:profile]
      end
    end

    private

    def github_profile(username)
      @@github_users ||= {}
      @@github_users[username] ||= load_github_profile_from_api(username)
    end

    def load_github_profile_from_api(username)
      response = HTTParty.get("https://api.github.com/users/#{username}")
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
