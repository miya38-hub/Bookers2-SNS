class UsersController < ApplicationController
  before_action :is_matching_login_user, only: [:edit, :update]
  allow_unauthenticated_access only: [:new, :create]

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user) # 登録と同時にログイン扱い
      redirect_to user_path(@user), notice: "Signed up successfully.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @users = User.all
    @user  = current_user
    @book  = Book.new
  end

  def show
    @user = User.find(params[:id])           # 表示したいユーザー
    @book = Book.new                         # 左側のNew book用（必要なら）
    @books = @user.books.order(created_at: :desc)  # そのユーザーの投稿本
  end

  def following
    @user = User.find(params[:id])
    @users = @user.followings
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers
  end

  private
 
    # name, email_address, password, password_confirmation を許可
  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation,:introduction, :profile_image)
  end

  def is_matching_login_user
    return redirect_to new_session_path, status: :see_other unless current_user

    # URLのidが自分じゃなければ自分の詳細へ
    if params[:id].to_i != current_user.id
      redirect_to user_path(current_user), status: :see_other
    end
  end
end