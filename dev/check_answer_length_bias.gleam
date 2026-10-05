//// Quiz-content quality checks run against the application's domain values.

import gleam/int
import gleam/io
import gleam/list
import gleam/string
import quiz/domain.{type Answer, type Question, type Quiz, Correct, Incorrect}
import quizzes/catalog

// TYPES -----------------------------------------------------------------------

type Inspection {
  Inspection(question_count: Int, invalid_count: Int, longest_count: Int)
}

// CHECK -----------------------------------------------------------------------

pub fn main() {
  let checks = catalog.all() |> list.map(inspect_quiz)

  case list.any(checks, fn(passed) { !passed }) {
    True -> panic as "Quiz-content quality check failed"
    False -> Nil
  }
}

fn inspect_quiz(quiz: Quiz) -> Bool {
  let inspection =
    list.fold(
      quiz.questions,
      Inspection(question_count: 0, invalid_count: 0, longest_count: 0),
      fn(inspection, question) {
        Inspection(
          question_count: inspection.question_count + 1,
          invalid_count: inspection.invalid_count + invalid_count(question),
          longest_count: inspection.longest_count + longest_count(question),
        )
      },
    )
  let longest_percentage = case inspection.question_count {
    0 -> 0
    count -> inspection.longest_count * 100 / count
  }

  io.println(
    quiz.title
    <> ": "
    <> int.to_string(inspection.longest_count)
    <> "/"
    <> int.to_string(inspection.question_count)
    <> " correct answers are strictly longest ("
    <> int.to_string(longest_percentage)
    <> "%)",
  )

  case inspection.invalid_count {
    0 -> Nil
    count ->
      io.println(
        quiz.title
        <> ": "
        <> int.to_string(count)
        <> " questions do not have four choices and one correct answer",
      )
  }

  inspection.invalid_count == 0
  && inspection.longest_count * 100 <= inspection.question_count * 35
}

// QUESTION INSPECTION ---------------------------------------------------------

fn invalid_count(question: Question) -> Int {
  let correct_count =
    question.answers
    |> list.filter(is_correct)
    |> list.length

  case list.length(question.answers) == 4 && correct_count == 1 {
    True -> 0
    False -> 1
  }
}

fn longest_count(question: Question) -> Int {
  let correct = list.filter(question.answers, is_correct)
  let incorrect =
    list.filter(question.answers, fn(answer) { !is_correct(answer) })

  case correct {
    [answer] -> bool_to_int(is_strictly_longest(answer, incorrect))
    _ -> 0
  }
}

fn is_strictly_longest(correct: Answer, incorrect: List(Answer)) -> Bool {
  list.all(incorrect, fn(answer) {
    string.length(correct.text) > string.length(answer.text)
  })
}

fn is_correct(answer: Answer) -> Bool {
  case answer.correctness {
    Correct -> True
    Incorrect -> False
  }
}

fn bool_to_int(value: Bool) -> Int {
  case value {
    True -> 1
    False -> 0
  }
}
