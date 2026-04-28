Add a new enum state to a model. Arguments: model name and state name (e.g. `BookRequest returned`).

Follow these steps in order:

1. **Model file** (`app/models/<model>.rb`) — add the new state to the enum hash. Always append at the end; never renumber existing values (the integers are persisted in the DB).

2. **Guard logic** — if the model is `BookRequest`, check whether `can_create?` or `can_request_again?` needs to handle the new state. Update if necessary.

3. **Factory trait** (`spec/factories/<models>.rb`) — add a trait for the new state:
   ```ruby
   trait :<state_name> do
     status { :<state_name> }
   end
   ```

4. **Model spec** (`spec/models/<model>_spec.rb`) — add an example that verifies the predicate method:
   ```ruby
   it 'is <state_name>' do
     record = build(:<factory>, :<state_name>)
     expect(record.<state_name>?).to be true
   end
   ```

5. **Summary** — list every file changed and note any controller actions or views that may also need updating (e.g. if the new state should affect UI display or routing logic).
