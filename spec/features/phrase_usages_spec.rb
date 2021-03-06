require "spec_helper"

RSpec.feature "phrase usages" do
  scenario "displays phrase usages which contain the selected phrase" do
    phrase = FactoryBot.create(:phrase, phrase_text: "how government works")
    survey = FactoryBot.create(:survey, started_at: DateTime.now - 2.days)
    survey_answers = FactoryBot.create_list(:survey_answer, 20, survey: survey)
    survey_answers.each { |survey_answer| FactoryBot.create(:mention, phrase: phrase, survey_answer: survey_answer) }

    visit usage_phrase_path(phrase)

    expect(page).to have_content("expected answer 1")
    expect(page).to have_link("Next page")
  end
end
