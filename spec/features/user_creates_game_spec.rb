require 'rails_helper'

# Описываем поведение функционала "Пользователь создает игру"
RSpec.feature 'USER creates game', type: :feature do
  # В базе должен быть пользователь
  let(:user) { FactoryBot.create :user }

  # В базе должно быть по одному вопросу каждого уровня
  # иначе игра не сможет создаться
  let!(:questions) do
    (0..14).to_a.map do |i|
      FactoryBot.create(
        :question, level: i,
        text: "Когда была куликовская битва номер #{i}?",
        answer1: '1380', answer2: '1381', answer3: '1382', answer4: '1383'
      )
    end
  end

  # Перед сценарием авторизуем пользователя, неавторизованные не могу играть
  before(:each) do
    login_as user
  end

  # Сценарий успешного начала игры
  scenario 'success' do
    # Посещаем главную страницу
    visit '/'

    # Ищем кнопку начала игры и нажимаем
    click_link 'Новая игра'

    # На том, что теперь види браузер проверяем данные
    expect(page).to have_content('Когда была куликовская битва номер 0?')

    expect(page).to have_content('1380')
    expect(page).to have_content('1381')
    expect(page).to have_content('1382')
    expect(page).to have_content('1383')
  end
end
