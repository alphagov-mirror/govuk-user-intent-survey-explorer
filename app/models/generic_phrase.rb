class GenericPhrase < ApplicationRecord
  belongs_to :verb
  belongs_to :adjective
  has_many :phrase_generic_phrases, dependent: :destroy

  def self.search(start_date, end_date, options = {})
    options = {
      sort_key: "generic_phrase",
      sort_dir: :asc,
      verb: "%",
      adjective: "%",
    }.merge!(options)

    date_range = start_date..end_date

    GenericPhrase
      .joins(:verb, :adjective, phrase_generic_phrases: [{ phrase: [{ mentions: [{ survey_answer: :survey }] }] }])
      .where("surveys.started_at" => date_range)
      .where("verbs.name like ?", options[:verb])
      .where("adjectives.name like ?", options[:adjective])
      .group("generic_phrases.id, verbs.name, adjectives.name")
      .order("#{options[:sort_key]} #{options[:sort_dir]}")
      .pluck("generic_phrases.id", "concat(verbs.name, '-', adjectives.name) as generic_phrase", "verbs.name as verb", "adjectives.name as adj")
  end

  def self.most_frequent_for_page(page, start_date, end_date)
    date_range = start_date..end_date

    GenericPhrase
        .select("generic_phrases.id, verbs.name, adjectives.name, count(phrase_generic_phrases.generic_phrase_id) as total_mentions")
        .joins(:verb, :adjective, phrase_generic_phrases: [{ phrase: [{ mentions: [{ survey_answer: [{ survey: [{ survey_visit: [{ visit: :page_visits }] }] }] }] }] }])
        .where("surveys.started_at" => date_range)
        .where("page_visits.page_id" => page.id)
        .group("generic_phrases.id, verbs.name, adjectives.name")
        .order("total_mentions desc, verbs.name asc, adjectives.name asc")
        .pluck("concat(verbs.name, '-', adjectives.name)", "count(phrase_generic_phrases.generic_phrase_id) as total_mentions")
        .map { |phrase_text, total| { phrase_text: phrase_text, total: total } }
  end
end
