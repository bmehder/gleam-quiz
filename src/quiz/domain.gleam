import gleam/list

pub type Answer {
  Answer(text: String, is_correct: Bool)
}

pub type Question {
  Question(prompt: String, answers: List(Answer), explanation: String)
}

pub type Quiz {
  Quiz(
    id: String,
    title: String,
    description: String,
    questions: List(Question),
  )
}

/// Build a question using the authoring convention that the correct answer is
/// supplied separately from its distractors.
pub fn question(
  prompt prompt: String,
  correct correct: String,
  incorrect incorrect: List(String),
  explanation explanation: String,
) -> Question {
  let answers = [
    Answer(text: correct, is_correct: True),
    ..list.map(incorrect, fn(answer) { Answer(text: answer, is_correct: False) })
  ]

  Question(prompt: prompt, answers: answers, explanation: explanation)
}

pub fn shuffled_questions(quiz: Quiz) -> List(Question) {
  quiz.questions
  |> list.map(fn(question) {
    Question(..question, answers: list.shuffle(question.answers))
  })
  |> list.shuffle
}
