//// Tests for quiz-domain construction and application state transitions.

import gleam/list
import gleeunit
import gleeunit/should
import quiz
import quiz/domain.{type Answer, Answer, Correct, Incorrect, Question, Quiz}

pub fn main() {
  gleeunit.main()
}

// QUESTION AUTHORING ----------------------------------------------------------

pub fn question_marks_only_the_supplied_correct_answer_test() {
  let Question(_, answers, _) =
    domain.question(
      prompt: "Which answer is correct?",
      correct: "This one",
      incorrect: ["Not this one", "Nor this one", "Not this either"],
      explanation: "The correct answer is supplied separately.",
    )

  answers
  |> list.map(fn(answer) { answer.correctness })
  |> should.equal([Correct, Incorrect, Incorrect, Incorrect])
}

pub fn shuffling_preserves_answers_and_correctness_test() {
  let question = sample_question()
  let quiz = Quiz("test", "Test", "A test quiz", [question])
  let assert [Question(_, shuffled_answers, _)] =
    domain.shuffled_questions(quiz)

  shuffled_answers
  |> list.length
  |> should.equal(4)

  shuffled_answers
  |> list.filter(is_correct)
  |> list.length
  |> should.equal(1)

  shuffled_answers
  |> list.all(fn(answer) { list.contains(question.answers, answer) })
  |> should.be_true
}

// STATE TRANSITIONS -----------------------------------------------------------

pub fn selecting_a_correct_answer_increments_the_score_test() {
  let correct = Answer("Correct", Correct)
  let attempt = sample_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      model_with_screen(quiz.Answering(attempt: attempt)),
      quiz.UserSelectedAnswer(correct),
    )

  model
  |> should.equal(
    model_with_screen(quiz.Reviewing(
      attempt: quiz.QuizAttempt(..attempt, score: 3),
      selected_answer: correct,
    )),
  )
}

pub fn selecting_an_incorrect_answer_preserves_the_score_test() {
  let incorrect = Answer("Incorrect", Incorrect)
  let attempt = sample_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      model_with_screen(quiz.Answering(attempt: attempt)),
      quiz.UserSelectedAnswer(incorrect),
    )

  model
  |> should.equal(
    model_with_screen(quiz.Reviewing(
      attempt: quiz.QuizAttempt(..attempt, score: 2),
      selected_answer: incorrect,
    )),
  )
}

pub fn moving_to_the_next_question_preserves_the_attempt_test() {
  let next_question = sample_question()
  let attempt =
    quiz.QuizAttempt(..sample_attempt(score: 2), remaining_questions: [
      next_question,
    ])
  let #(model, _) =
    quiz.update(
      model_with_screen(quiz.Reviewing(
        attempt: attempt,
        selected_answer: Answer("Correct", Correct),
      )),
      quiz.UserClickedNextQuestion,
    )

  model
  |> should.equal(
    model_with_screen(quiz.Answering(
      attempt: quiz.QuizAttempt(
        ..attempt,
        current_question: next_question,
        remaining_questions: [],
      ),
    )),
  )
}

pub fn completing_the_final_question_keeps_only_quiz_and_score_test() {
  let attempt = sample_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      model_with_screen(quiz.Reviewing(
        attempt: attempt,
        selected_answer: Answer("Correct", Correct),
      )),
      quiz.UserClickedNextQuestion,
    )

  model
  |> should.equal(
    model_with_screen(quiz.Finished(quiz: attempt.quiz, score: attempt.score)),
  )
}

pub fn cancelling_exit_confirmation_preserves_the_current_screen_test() {
  let screen = quiz.Answering(attempt: sample_attempt(score: 2))
  let #(confirming_model, _) =
    quiz.update(model_with_screen(screen), quiz.UserClickedChooseQuiz)

  confirming_model
  |> should.equal(quiz.Model(screen: screen, dialog: quiz.ConfirmingQuizExit))

  let #(cancelled_model, _) =
    quiz.update(confirming_model, quiz.UserCancelledQuizExit)

  cancelled_model
  |> should.equal(model_with_screen(screen))
}

pub fn confirming_quiz_exit_returns_to_the_catalogue_test() {
  let confirming_model =
    quiz.Model(
      screen: quiz.Answering(attempt: sample_attempt(score: 2)),
      dialog: quiz.ConfirmingQuizExit,
    )
  let #(model, _) = quiz.update(confirming_model, quiz.UserConfirmedQuizExit)

  model
  |> should.equal(quiz.initial_model())
}

// HELPERS ---------------------------------------------------------------------

fn model_with_screen(screen: quiz.Screen) -> quiz.Model {
  quiz.Model(screen: screen, dialog: quiz.NoDialog)
}

fn sample_attempt(score score: Int) -> quiz.QuizAttempt {
  quiz.QuizAttempt(
    quiz: Quiz("test", "Test", "A test quiz", [sample_question()]),
    current_question: sample_question(),
    remaining_questions: [],
    score: score,
  )
}

fn sample_question() -> domain.Question {
  domain.question(
    prompt: "Which answer is correct?",
    correct: "Correct",
    incorrect: ["Incorrect one", "Incorrect two", "Incorrect three"],
    explanation: "The answer marked Correct is correct.",
  )
}

fn is_correct(answer: Answer) -> Bool {
  answer.correctness == Correct
}
