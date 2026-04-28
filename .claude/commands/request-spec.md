Generate a request spec for the `$ARGUMENTS` controller following this project's conventions.

- File: `spec/requests/<name>_spec.rb`
- Describe block: `RSpec.describe <ControllerName>, type: :request`
- `let(:user) { FactoryBot.create(:user) }` at the top — lazy unless it must pre-exist
- `before { sign_in user }` in the outermost describe block
- Use `let!` only when the record must exist in the DB before the test body runs (e.g. testing "already exists" cases)
- Group actions with `describe 'GET /path'`, `describe 'POST /path'`, etc.
- Use `context 'with valid params'` / `context 'with invalid params'` for branching
- Check HTTP status, redirects, and `assigns` for each action
- Use `expect { ... }.to change(Model, :count).by(1)` for create/destroy
- Canonical example to follow: `spec/requests/books_spec.rb`
