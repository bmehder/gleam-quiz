const quizExitDialogId = "quiz-exit-dialog";

export function showQuizExit() {
  const dialog = document.getElementById(quizExitDialogId);

  if (dialog instanceof HTMLDialogElement && !dialog.open) {
    dialog.showModal();
  }
}
