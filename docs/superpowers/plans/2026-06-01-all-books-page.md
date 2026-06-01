# All Books Page & Friendship Borrow Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a paginated "All Books" page visible to all signed-in users that shows every book in the system with its owner, and restrict the "Ask to Lend" button to friends of the book owner.

**Architecture:** Add a `kaminari`-paginated `all` action to `BooksController`, add the route as a collection member of `resources :books`, update the nav, and gate the borrow button in `_book_overview.html.erb` with a friendship check. A server-side guard in `BookRequestsController#create` prevents POST bypass.

**Tech Stack:** Rails 8.1, Ruby 3.3, kaminari (new), Tailwind CSS, RSpec + FactoryBot

---

## File Map

| File | Change |
|---|---|
| `Gemfile` | Add `kaminari` |
| `config/routes.rb` | Add `get :all` to `resources :books` collection |
| `app/controllers/books_controller.rb` | Add `all` action |
| `app/views/books/all.html.erb` | Create paginated all-books view |
| `app/views/layouts/_aside.html.erb` | Add "All Books" link in desktop nav + mobile menu |
| `app/views/common/_book_overview.html.erb` | Replace `elsif` branch with friendship-aware gate |
| `app/controllers/book_requests_controller.rb` | Add friendship guard before `can_create?` check |
| `spec/requests/books_spec.rb` | Add specs for `GET /books/all` |
| `spec/requests/book_requests_spec.rb` | Create file; add friendship guard spec |

---

### Task 1: Add kaminari gem

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Add gem to Gemfile**

Open `Gemfile` and add this line after the existing gems block (before the last `end`):

```ruby
gem 'kaminari'
```

- [ ] **Step 2: Install the gem**

```bash
bundle install
```

Expected: `Bundle complete!` with kaminari in the output.

- [ ] **Step 3: Generate kaminari config**

```bash
bundle exec rails generate kaminari:config
```

Expected: `create  config/initializers/kaminari_config.rb`

- [ ] **Step 4: Commit**

```bash
git add Gemfile Gemfile.lock config/initializers/kaminari_config.rb
git commit -m "feat: add kaminari for pagination"
```

---

### Task 2: Add route for All Books

**Files:**
- Modify: `config/routes.rb`

- [ ] **Step 1: Add `all` to the books collection**

In `config/routes.rb`, find the `resources :books` block:

```ruby
resources :books do
  collection do
    get :search
  end
  member do
    patch :lend
  end
end
```

Replace it with:

```ruby
resources :books do
  collection do
    get :search
    get :all
  end
  member do
    patch :lend
  end
end
```

- [ ] **Step 2: Verify the route exists**

```bash
bundle exec rails routes | grep all_books
```

Expected output includes:
```
all_books GET    /books/all(.:format)   books#all
```

- [ ] **Step 3: Commit**

```bash
git add config/routes.rb
git commit -m "feat: add all_books route"
```

---

### Task 3: Add `BooksController#all` action with spec

**Files:**
- Modify: `app/controllers/books_controller.rb`
- Modify: `spec/requests/books_spec.rb`

- [ ] **Step 1: Write the failing specs**

Open `spec/requests/books_spec.rb`. Add this block after the existing `describe 'GET /books'` block (before the final `end`):

```ruby
describe 'GET /books/all' do
  it 'returns 200' do
    get all_books_path
    expect(response).to have_http_status(:ok)
  end

  it 'includes books from other users' do
    other_user = FactoryBot.create(:user)
    other_book = FactoryBot.create(:book, user: other_user)

    get all_books_path

    expect(assigns(:books)).to include(other_book)
  end

  it 'includes the current user own books' do
    own_book = FactoryBot.create(:book, user: user)

    get all_books_path

    expect(assigns(:books)).to include(own_book)
  end
end
```

- [ ] **Step 2: Run specs to verify they fail**

```bash
bundle exec rspec spec/requests/books_spec.rb --format documentation 2>&1 | grep -A2 "GET /books/all"
```

Expected: 3 failures mentioning `AbstractController::ActionNotFound` or similar.

- [ ] **Step 3: Add the `all` action to `BooksController`**

Open `app/controllers/books_controller.rb`. Add this action after the `index` action (after its closing `end`):

```ruby
def all
  @books = Book.includes(:user).order(created_at: :desc).page(params[:page]).per(24)
end
```

- [ ] **Step 4: Run specs to verify they pass**

```bash
bundle exec rspec spec/requests/books_spec.rb --format documentation 2>&1 | grep -A2 "GET /books/all"
```

Expected: 3 examples, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add app/controllers/books_controller.rb spec/requests/books_spec.rb
git commit -m "feat: add BooksController#all action with specs"
```

---

### Task 4: Create the All Books view

**Files:**
- Create: `app/views/books/all.html.erb`

- [ ] **Step 1: Create the view file**

Create `app/views/books/all.html.erb` with this content:

```erb
<div class="p-6 flex flex-col gap-6">
  <h1 class="text-3xl font-bold text-[#3b2a1a]">All Books</h1>

  <% if @books.any? %>
    <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
      <% @books.each do |book| %>
        <% cover = book.image.attached? ? url_for(book.image) : book.cover_url %>
        <%= link_to book_path(book), data: { turbo: false }, class: "book-card flex flex-col gap-1" do %>
          <div class="book-spine">
            <% if cover.present? %>
              <img src="<%= cover %>" alt="<%= book.title %>" class="book-cover">
            <% end %>
          </div>
          <div class="book-title-spine"><%= book.title %></div>
          <div class="book-author-spine"><%= book.author %></div>
          <p class="text-xs text-[#a08060] truncate">
            <%= link_to "#{book.user.first_name} #{book.user.last_name}", user_books_path(book.user), data: { turbo: false }, class: "underline hover:text-[#3b2a1a]" %>
          </p>
          <% if book.lent? %>
            <span class="text-xs font-semibold text-red-500">Lent</span>
          <% end %>
        <% end %>
      <% end %>
    </div>

    <div class="flex justify-center mt-4">
      <%= paginate @books %>
    </div>
  <% else %>
    <p class="text-[#a08060] italic text-center py-8">No books yet.</p>
  <% end %>
</div>
```

- [ ] **Step 2: Verify the page renders**

Start the dev server (`./bin/dev`) and navigate to `/books/all`. Confirm the page loads, shows book cards with owner names, and paginates if there are more than 24 books.

- [ ] **Step 3: Commit**

```bash
git add app/views/books/all.html.erb
git commit -m "feat: add All Books paginated view"
```

---

### Task 5: Add "All Books" to navigation

**Files:**
- Modify: `app/views/layouts/_aside.html.erb`

- [ ] **Step 1: Add to desktop nav**

In `app/views/layouts/_aside.html.erb`, find the desktop nav list item for "My Books":

```erb
<li class="header-item"><%= link_to  "My Books", books_path %></li>
```

Add "All Books" immediately after it:

```erb
<li class="header-item"><%= link_to  "My Books", books_path %></li>
<li class="header-item"><%= link_to  "All Books", all_books_path %></li>
```

- [ ] **Step 2: Add to mobile burger menu**

In the same file, find the mobile menu link for "My Books":

```erb
<%= link_to "My Books", books_path, class: "header-item" %>
```

Add "All Books" immediately after it:

```erb
<%= link_to "My Books", books_path, class: "header-item" %>
<%= link_to "All Books", all_books_path, class: "header-item" %>
```

- [ ] **Step 3: Verify in browser**

Reload the app. Confirm "All Books" appears in the desktop nav between "My Books" and "What's new", and in the mobile burger menu.

- [ ] **Step 4: Commit**

```bash
git add app/views/layouts/_aside.html.erb
git commit -m "feat: add All Books link to navigation"
```

---

### Task 6: Add friendship gate to book show page

**Files:**
- Modify: `app/views/common/_book_overview.html.erb`

- [ ] **Step 1: Replace the non-owner branch with a friendship-aware gate**

In `app/views/common/_book_overview.html.erb`, find and replace the entire `elsif @user.blank? && !@book_owner` block:

**Find (the entire block from `elsif` to the line before `else`):**

```erb
<% elsif @user.blank? && !@book_owner %>
        <p>You took this book from <%= @borrowed_book.borrower.first_name %> <%= @borrowed_book.borrower.last_name %></p>
```

**Replace with:**

```erb
<% elsif @user.blank? && !@book_owner %>
        <% if current_user.friends.exists?(@book.user.id) %>
            <% if @book_request %>
                <% if @book_request.status == "pending" %>
                    <p class="pt-6">You already asked this book. Please wait for the owner's decision.</p>
                <% elsif @book_request&.accepted? %>
                    <% if @book.lent? %>
                        <p class="pt-6">Owner accepted your request. Enjoy reading.</p>
                    <% else %>
                        <p class="pt-6">You have read this book, but you can ask it again.</p>
                        <%= button_to "Ask to Lend", book_requests_path,
                                params: { book_request: { book_id: book.id } },
                                method: :post,
                                class: "button button-primary" %>
                    <% end %>
                <% elsif @book_request.declined? %>
                    <p class="pt-6">Owner declined your request. Please try again later.</p>
                    <% if @book_request.can_request_again? %>
                        <%= button_to "Ask to Lend", book_requests_path,
                            params: { book_request: { book_id: book.id } },
                            method: :post,
                            class: "button button-primary" %>
                    <% else %>
                        <p class="text-gray-400 text-sm">You can ask again <%= time_ago_in_words(@book_request.updated_at + 1.week) %> from now.</p>
                    <% end %>
                <% end %>
            <% else %>
                <%= button_to "Ask to Lend", book_requests_path,
                    params: { book_request: { book_id: book.id } },
                    method: :post,
                    class: "button button-primary" %>
            <% end %>
        <% else %>
            <div class="pt-6">
                <button class="button button-primary opacity-50 cursor-not-allowed" disabled>Ask to Lend</button>
                <p class="text-gray-400 text-sm mt-2">
                    You need to be friends with
                    <%= link_to "#{@book.user.first_name} #{@book.user.last_name}", user_path(@book.user), class: "underline" %>
                    to borrow this book.
                </p>
            </div>
        <% end %>
```

- [ ] **Step 2: Verify in browser**

1. Sign in as User A. Add a book.
2. Sign in as User B (not friends with A). Navigate to `/books/all`, click User A's book. Confirm the "Ask to Lend" button is greyed out with the friendship message.
3. Make User B friends with User A (via the UI). Navigate back to the book. Confirm the "Ask to Lend" button is now active.

- [ ] **Step 3: Commit**

```bash
git add app/views/common/_book_overview.html.erb
git commit -m "feat: gate Ask to Lend button behind friendship check"
```

---

### Task 7: Add server-side friendship guard in BookRequestsController

**Files:**
- Create: `spec/requests/book_requests_spec.rb`
- Modify: `app/controllers/book_requests_controller.rb`

- [ ] **Step 1: Create the spec file with failing tests**

Create `spec/requests/book_requests_spec.rb`:

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookRequestsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:owner) { FactoryBot.create(:user) }
  let(:book) { FactoryBot.create(:book, user: owner) }

  before { sign_in user }

  describe 'POST /book_requests' do
    context 'when requester is not friends with the book owner' do
      it 'redirects to the book page with an alert' do
        post book_requests_path, params: { book_request: { book_id: book.id } }

        expect(response).to redirect_to(book_path(book))
        expect(flash[:alert]).to eq('You must be friends with the owner to request this book.')
      end

      it 'does not create a book request' do
        expect {
          post book_requests_path, params: { book_request: { book_id: book.id } }
        }.not_to change(BookRequest, :count)
      end
    end

    context 'when requester is friends with the book owner' do
      before do
        FactoryBot.create(:friendship, user: user, friend: owner, status: :accepted)
      end

      it 'creates a book request' do
        expect {
          post book_requests_path, params: { book_request: { book_id: book.id } }
        }.to change(BookRequest, :count).by(1)
      end
    end
  end
end
```

- [ ] **Step 2: Run specs to verify they fail**

```bash
bundle exec rspec spec/requests/book_requests_spec.rb --format documentation
```

Expected: failures — the non-friend POST currently succeeds and creates a request.

- [ ] **Step 3: Add the friendship guard to `BookRequestsController#create`**

Open `app/controllers/book_requests_controller.rb`. Find the `create` action:

```ruby
def create
  case BookRequest.can_create?(book_request_params[:book_id], current_user)
```

Add the friendship guard before it:

```ruby
def create
  book = Book.find(book_request_params[:book_id])
  unless book.user == current_user || current_user.friends.exists?(book.user.id)
    redirect_to book_path(book), alert: 'You must be friends with the owner to request this book.'
    return
  end

  case BookRequest.can_create?(book_request_params[:book_id], current_user)
```

- [ ] **Step 4: Run specs to verify they pass**

```bash
bundle exec rspec spec/requests/book_requests_spec.rb --format documentation
```

Expected: 3 examples, 0 failures.

- [ ] **Step 5: Run the full test suite to check for regressions**

```bash
bundle exec rspec
```

Expected: all existing specs still pass.

- [ ] **Step 6: Commit**

```bash
git add app/controllers/book_requests_controller.rb spec/requests/book_requests_spec.rb
git commit -m "feat: add server-side friendship guard on book requests"
```
