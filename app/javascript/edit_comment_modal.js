window.openEditCommentModal = (id) => document.getElementById(`edit_comment_modal_${id}`)?.classList.remove('hidden')
window.closeEditCommentModal = (id) => document.getElementById(`edit_comment_modal_${id}`)?.classList.add('hidden')
