class Mention < ApplicationRecord
  belongs_to :phrase
  belongs_to :survey_answer

  def self.mentions_by_date_range_for_phrase(phrase, start_date, end_date)
    date_range = start_date..end_date

    mentions = Mention.joins(:phrase, survey_answer: :survey)
      .where(phrase: phrase, "surveys.started_at" => date_range)
      .group("date(surveys.started_at)")
      .limit(10)
      .pluck("date(surveys.started_at)", "count(mentions.id)")

    present_dates = mentions.map { |date, _| date }

    date_range.each do |date|
      unless present_dates.include?(date)
        mentions << [date, 0]
      end
    end

    mentions.sort
  end

  def self.mentions_by_date_range_for_generic_phrase(generic_phrase, start_date, end_date)
    date_range = start_date..end_date

    mentions = Mention.joins(phrase: :phrase_generic_phrases, survey_answer: :survey)
      .where("phrase_generic_phrases.generic_phrase_id" => generic_phrase.id, "surveys.started_at" => date_range)
      .group("date(surveys.started_at)")
      .limit(10)
      .pluck("date(surveys.started_at)", "count(phrase_generic_phrases.id)")

    present_dates = mentions.map { |date, _| date }

    date_range.each do |date|
      unless present_dates.include?(date)
        mentions << [date, 0]
      end
    end

    mentions.sort
  end
end
