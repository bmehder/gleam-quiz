import quiz/domain.{type Quiz}
import quizzes/functional_programming
import quizzes/gleam

pub fn all() -> List(Quiz) {
  [gleam.quiz(), functional_programming.quiz()]
}
