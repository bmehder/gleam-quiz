//// Native browser dialog actions exposed as managed Lustre effects.

import lustre/effect.{type Effect}

// EFFECTS ---------------------------------------------------------------------

pub fn show(id: String) -> Effect(message) {
  effect.before_paint(fn(_dispatch, _root) { show_modal(id) })
}

// BROWSER INTEROP -------------------------------------------------------------

@external(javascript, "./dialog_ffi.mjs", "showModal")
fn show_modal(id: String) -> Nil
