export function showModal(id) {
  const dialog = document.getElementById(id);

  if (dialog instanceof HTMLDialogElement && !dialog.open) {
    dialog.showModal();
  }
}
