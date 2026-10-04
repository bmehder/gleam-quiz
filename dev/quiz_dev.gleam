import lustre
import lustre/effect
import quiz
import timetravel

fn init(_arguments: Nil) {
  #(quiz.initial_model(), effect.none())
}

fn update(model: quiz.Model, msg: quiz.Msg) {
  #(quiz.update(model, msg), effect.none())
}

pub fn main() -> Nil {
  let app = timetravel.application(init, update, quiz.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
