# All Books Page & Friendship Borrow Gate

**Date:** 2026-06-01  
**Status:** Approved

---

## Overview

Add a global "All Books" page that lets any signed-in user browse every book in the system with owner attribution and pagination. Restrict the "Ask to Lend" action to friends of the book owner — enforced in both the view (disabled button + message) and the server (POST guard in the controller).

---

## Routes

Add one new named route before any existing `books` resources (to avoid shadowing):

```ruby
get '/books/all', to: 'books#all', as: :all_books
```

---

## Controller

### `BooksController#all` (new action)

```ruby
def all
  @books = Book.includes(:user).order(created_at: :desc).page(params[:page]).per(24)
end
```

- Uses `kaminari` for pagination (gem must be added to Gemfile).
- `includes(:user)` prevents N+1 when rendering owner names.
- No scope to `current_user` — shows all books in the system.

### `BookRequestsController#create` (guard added)

Before the existing `BookRequest.can_create?` check, add:

```ruby
book = Book.find(params[:book_request][:book_id])
unless current_user.friends.include?(book.user) || book.user == current_user
  redirect_to book_path(book), alert: "You must be friends with the owner to request this book."
  return
end
```

This prevents a direct POST bypass even when the UI shows a disabled button.

---

## Views

### Navigation (`app/views/layouts/_aside.html.erb`)

Add "All Books" link in both the desktop nav and the mobile burger menu, placed between "My Books" and "What's new":

```erb
<li class="header-item"><%= link_to "All Books", all_books_path %></li>
```

### All Books page (`app/views/books/all.html.erb`)

- Heading: "All Books"
- Paginated grid of book cards (24 per page), ordered newest first.
- Each card shows:
  - Book cover (Active Storage image, falling back to `cover_url`, falling back to a placeholder)
  - Title and author
  - Owner name linked to `user_books_path(book.user)`
  - "Lent" badge if `book.lent?`
- Clicking a card navigates to `book_path(book)`.
- Kaminari `paginate` helper at the bottom, styled to match existing UI.

### Book show page (`app/views/common/_book_overview.html.erb`)

Inside the `elsif @user.blank? && !@book_owner` branch, replace the current (incorrect) borrowed-book message with a friendship-aware block:

```ruby
friends_with_owner = current_user.friends.exists?(@book.user.id)
```

**If `friends_with_owner` is true:** render the existing "Ask to Lend" button flow unchanged.

**If `friends_with_owner` is false:** render a disabled "Ask to Lend" button (greyed, non-interactive) with the message:

> "You need to be friends with [linked owner name] to borrow this book."

Owner name links to `user_path(book.user)` so the visitor can navigate to their profile and send a friend request.

---

## Dependencies

| Dependency | Action |
|---|---|
| `kaminari` gem | Add to Gemfile, `bundle install`, run `rails generate kaminari:config` |

---

## What is NOT changing

- The `BooksController#index` action — still shows only the current user's books ("My Books").
- The existing book show page logic for the book owner and for borrowed books.
- Friend request flow — no changes to `Friendship` or `FriendshipsController`.
- Searchkick / Google Books search — unaffected.

---

## Testing

- Request spec for `GET /books/all`: returns 200, paginates correctly, includes books from other users.
- Request spec for `POST /book_requests`: returns redirect with alert when requester is not friends with owner.
- No model-layer changes — no model specs needed.
