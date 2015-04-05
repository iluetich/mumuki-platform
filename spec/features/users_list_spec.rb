require 'spec_helper'

feature 'Users listing' do
  let!(:new_user) { create(:user, name: 'foobar') }
  let!(:user_with_submissions) { create(:user, name: 'baz') }
  let(:exercise) { create(:exercise) }

  before do
    user_with_submissions.submissions.create(exercise: exercise, status: :failed, content: '')
  end

  scenario 'list users' do
    visit '/en/users'

    expect(page).to have_text('foobar')
    expect(page).to have_text('baz')
  end
end
