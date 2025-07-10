document.addEventListener('DOMContentLoaded', function() {
    const notesList = document.getElementById('notes-list');
    const addBtn = document.getElementById('add-note-btn');
    const titleInput = document.getElementById('note-title');
    const bodyInput = document.getElementById('note-body');
    const tagsInput = document.getElementById('note-tags');
    const notesMessage = document.getElementById('notes-message');

    let editingNoteId = null;
    let deletingNoteId = null;

    // Modal elements
    const editModal = document.getElementById('edit-modal');
    const deleteModal = document.getElementById('delete-modal');
    const editModalClose = document.getElementById('edit-modal-close');
    const deleteModalClose = document.getElementById('delete-modal-close');
    const saveEditBtn = document.getElementById('save-edit-btn');
    const confirmDeleteBtn = document.getElementById('confirm-delete-btn');
    const cancelDeleteBtn = document.getElementById('cancel-delete-btn');
    const editNoteTitle = document.getElementById('edit-note-title');
    const editNoteTags = document.getElementById('edit-note-tags');
    const editNoteBody = document.getElementById('edit-note-body');

    function showMessage(msg, isError) {
        notesMessage.textContent = msg;
        notesMessage.style.color = isError ? '#e57373' : '#6c63ff';
        notesMessage.style.display = 'block';
    }
    function hideMessage() {
        notesMessage.textContent = '';
        notesMessage.style.display = 'none';
    }

    function renderNotes(notes) {
        notesList.innerHTML = '';
        hideMessage();
        if (!Array.isArray(notes) || notes.length === 0) {
            showMessage('No notes found. Create your first note!', false);
            return;
        }
        notes.forEach(note => {
            const card = document.createElement('div');
            card.className = 'note-card';
            card.innerHTML = `
                <div class="note-card-title">${note.title}</div>
                <div class="note-card-tags">${note.tags ? note.tags.join(', ') : ''}</div>
                <div class="note-card-body">${note.body}</div>
                <div class="note-card-actions">
                    <button onclick="editNote('${note.id}')">Edit</button>
                    <button onclick="deleteNote('${note.id}')">Delete</button>
                </div>
            `;
            card.noteData = note;
            notesList.appendChild(card);
        });
    }

    async function fetchNotes() {
        try {
            const res = await fetch('/notes');
            if (!res.ok) throw new Error('Failed to fetch notes');
            const notes = await res.json();
            renderNotes(notes);
        } catch (err) {
            showMessage('Error loading notes: ' + err.message, true);
        }
    }

    addBtn.onclick = async function() {
        const title = titleInput.value.trim();
        const body = bodyInput.value.trim();
        const tags = tagsInput.value.split(',').map(t => t.trim()).filter(Boolean);
        if (!title || !body) {
            showMessage('Title and body are required.', true);
            return;
        }
        try {
            const res = await fetch('/notes', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ title, body, tags, user_id: getUserId() })
            });
            if (!res.ok) throw new Error('Failed to add note');
            titleInput.value = '';
            bodyInput.value = '';
            tagsInput.value = '';
            fetchNotes();
        } catch (err) {
            showMessage('Error adding note: ' + err.message, true);
        }
    };

    // Modal open/close helpers
    function openEditModal(note) {
        editingNoteId = note.id;
        editNoteTitle.value = note.title;
        editNoteTags.value = note.tags ? note.tags.join(', ') : '';
        editNoteBody.value = note.body;
        editModal.style.display = 'block';
    }
    function closeEditModal() {
        editingNoteId = null;
        editModal.style.display = 'none';
    }
    function openDeleteModal(noteId) {
        deletingNoteId = noteId;
        deleteModal.style.display = 'block';
    }
    function closeDeleteModal() {
        deletingNoteId = null;
        deleteModal.style.display = 'none';
    }

    // Modal event listeners
    editModalClose.onclick = closeEditModal;
    deleteModalClose.onclick = closeDeleteModal;
    cancelDeleteBtn.onclick = closeDeleteModal;
    window.onclick = function(event) {
        if (event.target === editModal) closeEditModal();
        if (event.target === deleteModal) closeDeleteModal();
    };

    saveEditBtn.onclick = async function() {
        if (!editingNoteId) return;
        const newTitle = editNoteTitle.value.trim();
        const newBody = editNoteBody.value.trim();
        const newTags = editNoteTags.value.split(',').map(t => t.trim()).filter(Boolean);
        if (!newTitle || !newBody) {
            showMessage('Title and body are required.', true);
            return;
        }
        try {
            const res = await fetch(`/notes/${editingNoteId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ title: newTitle, body: newBody, tags: newTags })
            });
            if (!res.ok) throw new Error('Failed to update note');
            closeEditModal();
            fetchNotes();
        } catch (err) {
            showMessage('Error updating note: ' + err.message, true);
        }
    };

    confirmDeleteBtn.onclick = async function() {
        if (!deletingNoteId) return;
        try {
            const res = await fetch(`/notes/${deletingNoteId}`, { method: 'DELETE' });
            if (!res.ok) throw new Error('Failed to delete note');
            closeDeleteModal();
            fetchNotes();
        } catch (err) {
            showMessage('Error deleting note: ' + err.message, true);
        }
    };

    // Override editNote and deleteNote to use modals
    window.editNote = function(id) {
        // Find the note in the current list
        const note = Array.from(notesList.children).map(card => card.noteData).find(n => n && n.id === id);
        // If not found, fetch from server
        if (note) {
            openEditModal(note);
        } else {
            // fallback: fetch from server
            fetch(`/notes/${id}`)
                .then(res => res.json())
                .then(note => openEditModal(note));
        }
    };
    window.deleteNote = function(id) {
        openDeleteModal(id);
    };

    function getUserId() {
        // Try to get userID from cookie (for demo, fallback to 'demo-user')
        const match = document.cookie.match(/userID=([^;]+)/);
        return match ? match[1] : 'demo-user';
    }

    fetchNotes();
}); 