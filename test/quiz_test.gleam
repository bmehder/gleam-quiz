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
      quiz.Answering(attempt: attempt),
      quiz.UserSelectedAnswer(correct),
    )

  model
  |> should.equal(quiz.Reviewing(
    attempt: quiz.QuizAttempt(..attempt, score: 3, answered_count: 1),
    selected_answer: correct,
  ))
}

pub fn selecting_an_incorrect_answer_preserves_the_score_test() {
  let incorrect = Answer("Incorrect", Incorrect)
  let attempt = sample_attempt(score: 2)
  let #(model, _) =
    quiz.update(
      quiz.Answering(attempt: attempt),
      quiz.UserSelectedAnswer(incorrect),
    )

  model
  |> should.equal(quiz.Reviewing(
    attempt: quiz.QuizAttempt(..attempt, score: 2, answered_count: 1),
    selected_answer: incorrect,
  ))
}

// HELPERS ---------------------------------------------------------------------

fn sample_attempt(score score: Int) -> quiz.QuizAttempt {
  quiz.QuizAttempt(
    quiz: Quiz("test", "Test", "A test quiz", [sample_question()]),
    current_question: sample_question(),
    remaining_questions: [],
    score: score,
    answered_count: 0,
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
