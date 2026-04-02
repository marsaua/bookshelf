# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 20_260_328_104_141) do
  create_table 'active_storage_attachments', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.string 'name', null: false
    t.bigint 'record_id', null: false
    t.string 'record_type', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.string 'content_type'
    t.datetime 'created_at', null: false
    t.string 'filename', null: false
    t.string 'key', null: false
    t.text 'metadata'
    t.string 'service_name', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'book_requests', force: :cascade do |t|
    t.integer 'book_id', null: false
    t.datetime 'created_at', null: false
    t.text 'message'
    t.integer 'requester_id', null: false
    t.integer 'status'
    t.datetime 'updated_at', null: false
    t.index ['book_id'], name: 'index_book_requests_on_book_id'
    t.index ['requester_id'], name: 'index_book_requests_on_requester_id'
  end

  create_table 'books', force: :cascade do |t|
    t.string 'author'
    t.string 'category'
    t.string 'cover_url'
    t.datetime 'created_at', null: false
    t.text 'description'
    t.string 'language'
    t.integer 'page_count'
    t.decimal 'price'
    t.string 'publisher'
    t.string 'title'
    t.datetime 'updated_at', null: false
    t.integer 'user_id', null: false
    t.index ['user_id'], name: 'index_books_on_user_id'
  end

  create_table 'comments', force: :cascade do |t|
    t.text 'body'
    t.integer 'book_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'user_id', null: false
    t.index ['book_id'], name: 'index_comments_on_book_id'
    t.index ['user_id'], name: 'index_comments_on_user_id'
  end

  create_table 'friendships', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.integer 'friend_id', null: false
    t.integer 'status'
    t.datetime 'updated_at', null: false
    t.integer 'user_id', null: false
    t.index ['friend_id'], name: 'index_friendships_on_friend_id'
    t.index ['user_id'], name: 'index_friendships_on_user_id'
  end

  create_table 'lent_books', force: :cascade do |t|
    t.integer 'book_id', null: false
    t.integer 'borrower_id'
    t.string 'borrower_name'
    t.datetime 'created_at', null: false
    t.integer 'lender_id', null: false
    t.datetime 'lent_at'
    t.datetime 'returned_at'
    t.datetime 'updated_at', null: false
    t.index ['book_id'], name: 'index_lent_books_on_book_id'
    t.index ['borrower_id'], name: 'index_lent_books_on_borrower_id'
    t.index ['lender_id'], name: 'index_lent_books_on_lender_id'
  end

  create_table 'ratings', force: :cascade do |t|
    t.integer 'book_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'user_id', null: false
    t.integer 'value', null: false
    t.index ['book_id'], name: 'index_ratings_on_book_id'
    t.index ['user_id'], name: 'index_ratings_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'avatar'
    t.datetime 'created_at', null: false
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'first_name'
    t.string 'last_name'
    t.datetime 'remember_created_at'
    t.datetime 'reset_password_sent_at'
    t.string 'reset_password_token'
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'book_requests', 'books'
  add_foreign_key 'book_requests', 'users', column: 'requester_id'
  add_foreign_key 'books', 'users'
  add_foreign_key 'comments', 'books'
  add_foreign_key 'comments', 'users'
  add_foreign_key 'friendships', 'users'
  add_foreign_key 'friendships', 'users', column: 'friend_id'
  add_foreign_key 'lent_books', 'books'
  add_foreign_key 'lent_books', 'users', column: 'borrower_id'
  add_foreign_key 'lent_books', 'users', column: 'lender_id'
  add_foreign_key 'ratings', 'books'
  add_foreign_key 'ratings', 'users'
end
