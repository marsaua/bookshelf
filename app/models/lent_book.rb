# frozen_string_literal: true

class LentBook < ApplicationRecord
  belongs_to :book
  belongs_to :lender, class_name: 'User'
  belongs_to :borrower, class_name: 'User', optional: true

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }

  def borrower_display
    borrower ? "#{borrower.first_name} #{borrower.last_name}" : borrower_name
  end
end
