require 'ostruct'

module SpeakerHelpers
  def all_speakers
    data.speakers
      .collect { |name, speaker_data| Speaker.new(name, speaker_data) }
  end

  private

  class Speaker
    attr_reader :name
    attr_reader :links
    attr_reader :talks

    def initialize(name, speaker_data)
      @name = name
      @talks = speaker_data[:talks]
      @links = speaker_data[:links]
    end
  end
end
