//// Native browser dialog actions exposed as managed Lustre effects.

import lustre/effect.{type Effect}

// EFFECTS ---------------------------------------------------------------------

pub fn show_quiz_exit() -> Effect(message) {
  effect.before_paint(fn(_dispatch, _root) { show_quiz_exit_dialog() })
}

// BROWSER INTEROP -------------------------------------------------------------

@external(javascript, "./dialog_ffi.mjs", "showQuizExit")
fn show_quiz_exit_dialog() -> Nil
