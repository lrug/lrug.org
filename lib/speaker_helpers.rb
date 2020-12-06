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
      @profile = OpenStruct.new speaker_data[:profile]
    end
  end
end
