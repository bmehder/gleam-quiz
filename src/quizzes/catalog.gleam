//// Catalog of quizzes available to the application.

import quiz/domain.{type Quiz}
import quizzes/functional_programming
import quizzes/gleam

// CATALOG ---------------------------------------------------------------------

pub fn all() -> List(Quiz) {
  [gleam.quiz(), functional_programming.quiz()]
}
