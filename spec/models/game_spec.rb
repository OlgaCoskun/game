# Стандартный rspec-овский помощник для rails-проекта
require 'rails_helper'

# Наш собственный класс с вспомогательными методами
require 'support/my_spec_helper'

# Тестовый сценарий для модели Игры
#
# В идеале — все методы должны быть покрыты тестами, в этом классе содержится
# ключевая логика игры и значит работы сайта.
RSpec.describe Game, type: :model do
  # Пользователь для создания игр
  let(:user) {FactoryBot.create(:user)}

  # Игра с прописанными игровыми вопросами
  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # Генерим 60 вопросов с 4х запасом по полю level, чтобы проверить работу
      # RANDOM при создании игры.
      generate_questions(60)

      game = nil

      # Создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
        # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
        # GameQuestion.count +15
        change(GameQuestion, :count).by(15).and(
          # Game.count не должен измениться
          change(Question, :count).by(0)
        )
      )

      # Проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      # Проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  # Тесты на основную игровую логику
  context 'game mechanics' do
    # Правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # Текущий уровень игры и статус
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      # Перешли на след. уровень
      expect(game_w_questions.current_level).to eq(level + 1)

      # Ранее текущий вопрос стал предыдущим
      expect(game_w_questions.current_game_question).not_to eq(q)

      # Игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end

  #Задание 61-3
  it 'take_money! finishes the game' do
    # берем игру и отвечаем на текущий вопрос
    q = game_w_questions.current_game_question
    game_w_questions.answer_current_question!(q.correct_answer_key)

    # взяли деньги
    game_w_questions.take_money!

    prize = game_w_questions.prize
    expect(prize).to be > 0

    # проверяем что закончилась игра и пришли деньги игроку
    expect(game_w_questions.status).to eq :money
    expect(game_w_questions.finished?).to be_truthy
    expect(user.balance).to eq prize
  end

  # Задание 61-6
  # Метод current_game_question возвращает текущий, еще неотвеченный вопрос игры
  context '#current_game_question' do
    let(:game_w_questions) do
      FactoryBot.create :game_with_questions
    end

    it 'ckeck current question' do
      expect(game_w_questions.current_game_question).to eq game_w_questions.game_questions[0]
    end
  end

  # Метод previous_level возвращает число, равное предыдущему уровню сложности
  context '#previous_level' do
    let(:game_w_questions) do
      FactoryBot.create :game_with_questions
    end

    it 'return number of past level' do
      expect(game_w_questions.previous_level).to eq game_w_questions.current_level - 1
    end
  end


  # Задание 61-4
  # группа тестов на проверку статуса игры
  context '.status' do
    # перед каждым тестом "завершаем игру"
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  # Задание 61-7
  # Группа тестов на проверку основных игровых методов
  describe '#answer_current_question!' do
    # Рассмотрите случаи, когда ответ правильный, неправильный,
    # последний (на миллион) и когда ответ дан после истечения времени.
    context 'when the answer is right' do
      let(:game_w_questions) do # let применяется для каждого it
        FactoryBot.create :game_with_questions,
                          current_level: 5
      end

      # - Вернуть true
      it 'return true' do
        result = game_w_questions.answer_current_question!('d')
        expect(result).to eq true
      end

      # - Проверить, что игра продолжилась (in_progress)
      it 'saves game status' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.status).to eq :in_progress
      end

      # - Проверить, что уровень переключился (+1)
      it 'increments game level' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.current_level).to eq 6
      end
    end

    context 'when the answer is wrong' do
      let(:game_w_questions) do # let применяется для каждого it
        FactoryBot.create :game_with_questions,
                          current_level: 5
      end

      # вернули false
      it 'return false' do
        result = game_w_questions.answer_current_question!('a')
        expect(result).to eq false
      end

      # статус игры стал :fail
      it 'fails the game' do
        game_w_questions.answer_current_question!('a')
        expect(game_w_questions.status).to eq :fail
      end

      # прописали несгораемую сумму в prize
      it 'updates prize' do
        game_w_questions.answer_current_question!('a')
        expect(game_w_questions.prize).to eq 1_000
      end

      # остался тот же current_level
      it 'saves game level' do
        game_w_questions.answer_current_question!('a')
        expect(game_w_questions.current_level).to eq 5
      end

      # вернули true для последнего ответа
      it 'returns true for last answer' do
        15.times do # Подсовываем правильный ответ d 15 раз, чтобы накрутить до 1_000_000 сумму
          game_w_questions.answer_current_question!('d')
        end
        expect(game_w_questions.prize).to eq 1_000_000
      end

      # вернули false когда время на ответ истекло. Здесь ответ передавать не будем, как бы пользователь не ответил.
      it 'returns false for timed out answer' do
        expect(game_w_questions.is_failed).to be false
      end
    end
  end
end
