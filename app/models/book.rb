class Book < ApplicationRecord
    belongs_to :user
    belongs_to :lent_to_user, class_name: "User", foreign_key: "lent_to_user_id", optional: true
    after_update :update_book_lent_to, if: -> { accepted? && saved_change_to_status? }

        
    validates :title, presence: true

    has_one_attached :image

    has_many :book_requests, dependent: :destroy

    def lent?
        lent_to_user_id.present? || lent_to_name.present?
    end

    def lent_to
        if lent_to_user
          "#{lent_to_user.first_name} #{lent_to_user.last_name}"
        else
          lent_to_name
        end
    end
end
