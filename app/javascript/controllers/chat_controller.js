import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  static targets = ["messages", "input", "modal", "headerMenu"];
  static values = {
    userId: Number,
    bookId: Number,
    currentUserId: Number,
    mode: String,
  };

  connect() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "ChatChannel",
        user_id: this.currentUserIdValue,
        receiver_id: this.userIdValue,
        book_id: this.bookIdValue,
      },
      {
        received: (data) => {
          if (data.type === "delete") {
            this.removeMessageFromDom(data.message_id);
            return;
          }
          if (data.type === "delete_conversation") {
            this.messagesTarget.innerHTML =
              '<p class="text-center text-sm opacity-50 pt-8">Conversation was deleted.</p>';
            return;
          }
          if (data.sender_id !== this.currentUserIdValue) {
            this.appendMessage(data, false);
          }
        },
      },
    );

    if (this.modeValue === "page") this.scrollToBottom();

    this._outsideClick = this.closeAllMenus.bind(this);
    document.addEventListener("click", this._outsideClick);
  }

  disconnect() {
    this.subscription?.unsubscribe();
    document.body.style.overflow = "";
    document.removeEventListener("click", this._outsideClick);
  }

  // ── Modal ──────────────────────────────────────────

  open() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden");
      document.body.style.overflow = "hidden";
    }
    this.scrollToBottom();
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden");
      document.body.style.overflow = "";
    }
  }

  // ── Send ───────────────────────────────────────────

  async send(event) {
    event.preventDefault();
    const body = this.inputTarget.value.trim();
    if (!body) return;

    const res = await fetch("/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json",
      },
      body: JSON.stringify({
        body,
        receiver_id: this.userIdValue,
        book_id: this.bookIdValue,
      }),
    });

    if (res.ok) {
      const { message_id } = await res.json();
      this.appendMessage(
        {
          message: body,
          message_id,
          sender_name: "You",
          created_at: new Date().toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
        },
        true,
      );
      this.inputTarget.value = "";
    }
  }

  // ── Menus ──────────────────────────────────────────

  toggleMessageMenu(event) {
    event.stopPropagation();
    const menu = event.currentTarget.querySelector(".message__menu");
    if (!menu) return;
    const wasHidden = menu.classList.contains("hidden");
    this.closeAllMenus();
    if (wasHidden) menu.classList.remove("hidden");
  }

  toggleHeaderMenu(event) {
    event.stopPropagation();
    if (!this.hasHeaderMenuTarget) return;
    const wasHidden = this.headerMenuTarget.classList.contains("hidden");
    this.closeAllMenus();
    if (wasHidden) this.headerMenuTarget.classList.remove("hidden");
  }

  closeAllMenus() {
    this.element
      .querySelectorAll(".message__menu, .chat__header-menu")
      .forEach((m) => m.classList.add("hidden"));
  }

  // ── Delete single message ──────────────────────────

  async deleteMessage(event) {
    event.stopPropagation();
    const { messageId, scope } = event.currentTarget.dataset;

    const res = await fetch(`/messages/${messageId}?scope=${scope}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json",
      },
    });

    if (res.ok) this.removeMessageFromDom(parseInt(messageId));
  }

  removeMessageFromDom(messageId) {
    const el = this.messagesTarget.querySelector(`[data-message-id="${messageId}"]`);
    if (!el) return;
    el.classList.add("message--deleting");
    setTimeout(() => el.remove(), 200);
  }

  // ── Delete conversation ────────────────────────────

  async deleteConversation(event) {
    event.stopPropagation();
    const { scope } = event.currentTarget.dataset;
    const menu = this.hasHeaderMenuTarget ? this.headerMenuTarget : null;
    const userId = menu?.dataset.userId || this.userIdValue;
    const bookId = menu?.dataset.bookId || this.bookIdValue;

    const label = scope === "for_all" ? "delete for everyone" : "delete for yourself only";
    if (!confirm(`Are you sure you want to ${label}? This cannot be undone.`)) return;

    const res = await fetch(
      `/messages/destroy_conversation?user_id=${userId}&book_id=${bookId}&scope=${scope}`,
      {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json",
        },
      },
    );

    if (res.ok) {
      if (this.modeValue === "modal") {
        this.messagesTarget.innerHTML =
          '<p class="text-center text-sm opacity-50 pt-8">Conversation deleted.</p>';
        this.closeAllMenus();
      } else {
        window.location.href = "/messages";
      }
    }
  }

  // ── Helpers ────────────────────────────────────────

  appendMessage(data, isMine) {
    const empty = this.messagesTarget.querySelector("p");
    if (empty) empty.remove();

    const div = document.createElement("div");
    div.classList.add("message", isMine ? "mine" : "theirs");
    if (data.message_id) div.dataset.messageId = data.message_id;

    const menuHtml = (messageId, isSender) => {
      if (!messageId) return "";
      const deleteForAll = isSender
        ? `<button class="message__menu-item message__menu-item--danger"
                   data-action="click->chat#deleteMessage"
                   data-message-id="${messageId}" data-scope="for_all">Delete for everyone</button>`
        : "";
      return `
        <div class="message__menu-wrapper" data-action="click->chat#toggleMessageMenu">
          <button class="message__menu-btn">⋮</button>
          <div class="message__menu hidden" data-message-id="${messageId}" ${isSender ? 'data-is-sender="true"' : ""}>
            <button class="message__menu-item"
                    data-action="click->chat#deleteMessage"
                    data-message-id="${messageId}" data-scope="for_me">Delete for me</button>
            ${deleteForAll}
          </div>
        </div>`;
    };

    div.innerHTML = `
      <span class="message__name">${data.sender_name}</span>
      <div class="message__bubble-row">
        ${isMine ? menuHtml(data.message_id, true) : ""}
        <p class="message__body">${data.message}</p>
        ${!isMine ? menuHtml(data.message_id, false) : ""}
      </div>
      <span class="message__time">${data.created_at}</span>
    `;

    this.messagesTarget.appendChild(div);
    this.scrollToBottom();
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }
}
