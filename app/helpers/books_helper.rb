module BooksHelper
  BOOK_COLORS = %w[#c0392b #e67e22 #27ae60 #2980b9 #8e44ad #16a085 #d35400 #1a5276 #6d4c41 #558b2f].freeze

  def book_color(id)
    BOOK_COLORS[id % BOOK_COLORS.length]
  end
end
