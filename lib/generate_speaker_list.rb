# This file opens the meeting markdown files
# and attempts to extract the speakers & their 

require './lib/generate_speaker_list/generator'
require './lib/generate_speaker_list/parse_file'
require './lib/generate_speaker_list/parse_agenda'
require './lib/generate_speaker_list/parse_agenda_item'

GenerateSpeakerList::Generator.new.call
