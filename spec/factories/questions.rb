FactoryBot.define do
  factory :question do
    # Последовательность уникальных текстов вопроса
    sequence(:text) { |n| "В каком году была космичесая одиссея #{n}?" }

    # Уровни генерим от 0 до 14 подряд
    sequence(:level) { |n| n % 15}

    # Ответы сделаем рандомными для красоты
    answer1 {"#{rand(2001)}"}
    answer2 {"#{rand(2001)}"}
    answer3 {"#{rand(2001)}"}
    answer4 {"#{rand(2001)}"}
  end
end