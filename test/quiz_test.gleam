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
  let quiz_attempt = sample_quiz_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      quiz.AnsweringQuestion(quiz_attempt: quiz_attempt),
      quiz.UserSelectedAnswer(correct),
    )

  model
  |> should.equal(quiz.ReviewingQuestion(
    quiz_attempt: quiz.QuizAttempt(..quiz_attempt, score: 3),
    selected_answer: correct,
  ))
}

pub fn selecting_an_incorrect_answer_preserves_the_score_test() {
  let incorrect = Answer("Incorrect", Incorrect)
  let quiz_attempt = sample_quiz_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      quiz.AnsweringQuestion(quiz_attempt: quiz_attempt),
      quiz.UserSelectedAnswer(incorrect),
    )

  model
  |> should.equal(quiz.ReviewingQuestion(
    quiz_attempt: quiz.QuizAttempt(..quiz_attempt, score: 2),
    selected_answer: incorrect,
  ))
}

pub fn moving_to_the_next_question_preserves_the_attempt_test() {
  let next_question = sample_question()
  let quiz_attempt =
    quiz.QuizAttempt(..sample_quiz_attempt(score: 2), remaining_questions: [
      next_question,
    ])
  let #(model, _) =
    quiz.update(
      quiz.ReviewingQuestion(
        quiz_attempt: quiz_attempt,
        selected_answer: Answer("Correct", Correct),
      ),
      quiz.UserClickedNextQuestion,
    )

  model
  |> should.equal(quiz.AnsweringQuestion(
    quiz_attempt: quiz.QuizAttempt(
      ..quiz_attempt,
      current_question: next_question,
      remaining_questions: [],
    ),
  ))
}

pub fn completing_the_final_question_keeps_only_quiz_and_score_test() {
  let quiz_attempt = sample_quiz_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      quiz.ReviewingQuestion(
        quiz_attempt: quiz_attempt,
        selected_answer: Answer("Correct", Correct),
      ),
      quiz.UserClickedNextQuestion,
    )

  model
  |> should.equal(quiz.FinishedQuiz(
    quiz: quiz_attempt.quiz,
    score: quiz_attempt.score,
  ))
}

pub fn opening_exit_confirmation_does_not_change_the_model_test() {
  let model =
    quiz.AnsweringQuestion(quiz_attempt: sample_quiz_attempt(score: 2))
  let #(next_model, _) = quiz.update(model, quiz.UserClickedChooseQuiz)

  next_model
  |> should.equal(model)
}

pub fn confirming_quiz_exit_returns_to_the_catalogue_test() {
  let model =
    quiz.AnsweringQuestion(quiz_attempt: sample_quiz_attempt(score: 2))
  let #(model, _) = quiz.update(model, quiz.UserConfirmedQuizExit)

  model
  |> should.equal(quiz.initial_model())
}

// HELPERS ---------------------------------------------------------------------

fn sample_quiz_attempt(score score: Int) -> quiz.QuizAttempt {
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
