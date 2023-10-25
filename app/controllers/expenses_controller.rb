class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @category = Category.find(params[:category_id])
    @expenses = @category.expenses.order(created_at: :desc)
    @total = @expenses.sum(:amount)
  end

  def new
    @category = Category.find(params[:category_id])
    @expense = Expense.new
    @categories = Category.all
  end

  def create
    @category = Category.find(params[:category_id])
    @expense = @category.expenses.build(expense_params)

    if @expense.save
      redirect_to category_expenses_path(category_id: @category.id), notice: 'Expense was successfully created.'
    else
      flash.now[:alert] = 'Expense cannot be created.'
      render :new
    end
  end

  def destroy
    @expense = Expense.find(params[:id])
    @expense.categories.each do |category|
      category.category_expenses.find_by(expense_id: @expense.id).destroy
    end
  
    @expense.destroy
    redirect_to category_expenses_path(category_id: params[:category_id]), alert: 'Expense deleted successfully.'
  end
    
  private

  def expense_params
    params.require(:expense).permit(:name, :amount, category_ids: []).merge(author_id: current_user.id)
  end

end
