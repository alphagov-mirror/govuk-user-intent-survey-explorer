class GenericPhrasePresenter
  attr_reader :generic_phrase, :most_frequent_exact_matches, :mentions, :survey_answers, :most_frequent_co_occurring_generic_phrases

  def initialize(generic_phrase, most_frequent_exact_matches, mentions, survey_answers, most_frequent_co_occurring_generic_phrases)
    @generic_phrase = generic_phrase
    @most_frequent_exact_matches = most_frequent_exact_matches
    @mentions = mentions
    @survey_answers = survey_answers
    @most_frequent_co_occurring_generic_phrases = most_frequent_co_occurring_generic_phrases
  end

  def first_appeared_at
    generic_phrase.first_appeared_at.strftime("#{generic_phrase.first_appeared_at.day.ordinalize} %B %Y")
  end

  def title
    "Generic phrase #{generic_phrase}"
  end
end
