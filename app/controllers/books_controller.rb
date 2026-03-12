class BooksController < ApplicationController
    before_action :authenticate_user!
    before_action :set_book, only: %i[show edit update destroy lend ]

    def index
        @categories = current_user.books.where.not(category: [nil, ""]).distinct.pluck(:category)
        @my_books = current_user.books.where(lent_to_user_id: nil, lent_to_name: nil)
        @lent_books = current_user.books.where.not(lent_to_user_id: nil).or(
            current_user.books.where.not(lent_to_name: nil)
          )

        if params[:category].present?
            @my_books = @my_books.where(category: params[:category])
            @lent_books = @lent_books.where(category: params[:category])
        end
    end

    def show
    end

    def new
        @book = Book.new
    end

    def create
        @book = current_user.books.build(book_params)
        if @book.save
            redirect_to books_path, notice: "Book added!"
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @book.update(book_params)
            redirect_to books_path
        else
            render :edit, status: :unprocessable_entity
        end
    end
    def lend
        if params[:lent_to_user_id].present? || params[:lent_to_name].present?
            @book.update(
            lent_to_user_id: params[:lent_to_user_id],
            lent_to_name: params[:lent_to_name]
            )
        else
            @book.update(lent_to_user_id: nil, lent_to_name: nil)
        end
        redirect_to books_path
    end

    def search
        return render json: [] if params[:query].blank?
        @results = GoogleBooksService.search(params[:query])
        render json: @results
    end

    def destroy
        @book.destroy
        redirect_to books_path
    end

    private

    def set_book
        @book = current_user.books.find(params[:id])
    end

    def book_params
        params.require(:book).permit(:title, :author, :description, :cover_url, :image, :category)
    end
end
