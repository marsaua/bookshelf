Explain the full lending flow in this codebase with exact file and line references. Cover these five points in order:

1. **Permission check** — `BookRequest.can_create?` in `app/models/book_request.rb`. What each return value (`:ok`, `:pending`, `:wait`, `:lent`) means and when it fires.
2. **Request creation** — `BookRequestsController#create` in `app/controllers/book_requests_controller.rb`. How it branches on `can_create?` and triggers `BookMailer`.
3. **Owner accepts** — `BookRequestsController#accept`: flips status to `accepted!`, creates a `LentBook` record.
4. **Direct lend (no request)** — `BooksController#lend` in `app/controllers/books_controller.rb`. How the same action handles both lending out (via `lent_to_user_id` / `lent_to_name`) and returning (neither param present → sets `returned_at`).
5. **LentBook record** — `app/models/lent_book.rb`. The `active` scope, optional `borrower` (for non-users), and `borrower_display`.

End with a list of every file that needs to change if the flow is extended.
