import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  static targets = ["messages", "input", "modal"];
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
          if (data.sender_id !== this.currentUserIdValue) {
            this.appendMessage(data, false);
          }
        },
      },
    );

    if (this.modeValue === "page") {
      this.scrollToBottom();
    }
  }

  disconnect() {
    this.subscription?.unsubscribe();
    document.body.style.overflow = "";
  }

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

  async send(event) {
    event.preventDefault();
    const body = this.inputTarget.value.trim();
    if (!body) return;

    await fetch("/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        body,
        receiver_id: this.userIdValue,
        book_id: this.bookIdValue,
      }),
    });

    this.appendMessage(
      {
        message: body,
        sender_name: "Ти",
        created_at: new Date().toLocaleTimeString("uk-UA", {
          hour: "2-digit",
          minute: "2-digit",
        }),
      },
      true,
    );

    this.inputTarget.value = "";
  }

  appendMessage(data, isMine) {
    const div = document.createElement("div");
    div.classList.add("message", isMine ? "mine" : "theirs");
    div.innerHTML = `
      <span class="message__name">${data.sender_name}</span>
      <p class="message__body">${data.message}</p>
      <span class="message__time">${data.created_at}</span>
    `;
    this.messagesTarget.appendChild(div);
    this.scrollToBottom();
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }
}
