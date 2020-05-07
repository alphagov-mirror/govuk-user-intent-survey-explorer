class Phrase < ApplicationRecord
  has_many :mentions, dependent: :destroy
  has_many :survey_answers, through: :mentions

  def self.most_frequent(start_date, end_date)
    date_range = start_date..end_date

    Phrase.select("phrases.id, phrases.phrase_text, count(mentions.phrase_id) as total_mentions")
      .joins(mentions: [{ survey_answer: :survey }])
      .where("surveys.started_at" => date_range)
      .group("phrases.id, phrases.phrase_text")
      .order("total_mentions desc")
  end

  def self.top_phrases_for_page(page_id, start_date, end_date)
    date_range = start_date..end_date

    Phrase.joins(mentions: [{ survey_answer: [{ survey: [{ survey_visit: [{ visit: :page_visits }] }] }] }])
      .where("surveys.started_at" => date_range)
      .where("page_visits.page_id" => page_id)
      .group("phrases.id")
      .order("count(mentions.survey_answer_id) desc")
      .pluck("phrases.phrase_text")
  end
end
