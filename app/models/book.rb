class Book < ApplicationRecord
    belongs_to :user
    belongs_to :lent_to_user, class_name: "User", foreign_key: "lent_to_user_id", optional: true
        
    validates :title, presence: true

    has_one_attached :image

    def lent?
        lent_to_user_id.present? || lent_to_name.present?
    end

    def lent_to
        lent_to_user&.first_name || lent_to_name
    end
end
