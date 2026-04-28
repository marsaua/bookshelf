Explain how Google Books search results flow into Book records in this codebase.

Key facts to cover:
- Service: `app/services/google_books_service.rb`, class method `GoogleBooksService.search(query)`
- Requires `GOOGLE_BOOKS_API_KEY` env var (see `.env`)
- Returns up to 5 results as hashes with these keys: `title`, `author`, `description`, `image`, `category`, `publisher`, `language`, `pageCount`
- Field mapping gotchas:
  - `pageCount` (camelCase from API) → `Book#page_count` (snake_case column)
  - `image` from the API is a thumbnail URL → maps to `Book#cover_url` (a plain string column)
  - `Book#image` is a separate field — an Active Storage attachment stored on Cloudinary; do NOT confuse the two
- Route: `GET /books/search` returns JSON; the Stimulus/importmap JS populates the new-book form from this response
- Created books are owned by `current_user`

If `$ARGUMENTS` is provided, trace that specific scenario. Otherwise give the full overview.
