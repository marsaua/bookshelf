# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start development server (Rails + Tailwind CSS watcher)
./bin/dev

# Run full test suite
bundle exec rspec

# Run a single test file
bundle exec rspec spec/requests/ratings_spec.rb

# Run a single test by line number
bundle exec rspec spec/models/user_spec.rb:6

# Lint
bundle exec rubocop
bundle exec rubocop -A  # auto-correct

# Database
bin/rails db:create db:migrate db:seed
```

## Architecture

**Bookshelf** is a social book-sharing Rails 8.1 app (Ruby 3.3) where users manage personal book collections, lend/borrow books with friends, and leave ratings and comments.

### Core Models & Relationships

- **User** (Devise) — owns books, has friendships, makes book requests, leaves ratings/comments, has one attached avatar
- **Book** — belongs to a user (owner), has many requests/ratings/comments, has one attached image. `lent?` and `average_rating` are key helper methods.
- **BookRequest** — a borrow request from a requester (User) for a specific book. Status enum: `pending / accepted / declined / lent`. Has a 1-week cooldown after decline (`can_request_again?`). `BookRequest.can_create?` centralizes permission logic.
- **LentBook** — tracks active and historical lending transactions. Has both a `borrower` (User, optional) and a `borrower_name` string field to support lending to non-users. Scopes: `active` (no `returned_at`) and `returned`.
- **Friendship** — directional friend request record with `pending / accepted / rejected` enum. `Friendship.between(a, b)` finds relationships in either direction.
- **Rating** — value 1–5, unique per user/book.
- **Comment** — simple text comment, belongs to user and book.

### Key Patterns

- **Dual friendship classes**: Both `Friendship` and `Friend` models exist. `User#friends` goes through the `Friend` model for accepted connections; use `Friendship` for managing request state.
- **Enum-driven state machines**: `BookRequest`, `Friendship`, and `LentBook` all use Rails enums for status. Always use the enum predicate methods (e.g., `request.accepted?`) rather than comparing integers.
- **Service objects**: `GoogleBooksService` (book search via external API) and `MailgunService` (email delivery). `BookMailer` sends notifications on new book requests.
- **Routes**: Books can be nested under users (`/users/:user_id/books`) for viewing another user's shelf. Book-specific actions like `lend` are nested under books (`PATCH /books/:id/lend`). Search hits `GET /books/search` and returns JSON.

### Test Setup

- **RSpec + FactoryBot + Faker + Shoulda Matchers** — all configured in `spec/rails_helper.rb`
- Devise test helpers are enabled for request specs via `config.include Devise::Test::IntegrationHelpers`
- Use `let!` (eager) when a record must exist in the DB before the test runs (e.g., testing "already exists" scenarios). Use `let` (lazy) otherwise.
- Factories live in `spec/factories/`. Traits exist for statuses (e.g., `:accepted` on friendships).

## Rules

- Never renumber existing enum values — `BookRequest`, `Friendship`, and `LentBook` persist integers to the DB. New states always append at the end of the hash.
- Always go through `BookRequest.can_create?` before creating a request. Permission logic lives there, not in controllers.
- `Book#cover_url` is a plain URL string (from Google Books). `Book#image` is an Active Storage attachment (Cloudinary). They are different fields — don't conflate them.
- Use enum predicate methods (`request.accepted?`), not integer comparisons (`request.status == 1`).
- Scope mutating book actions to `current_user.books.find(params[:id])`, not `Book.find`. The `show` action is the only exception.
- In specs, use `let!` only when the record must exist before the test body runs. Use `let` otherwise.
- Use `Friendship.between(a, b)` when checking if two users have any relationship — it handles both directions.
