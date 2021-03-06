class UsersController < ApplicationController
  before_action :correct_user,   only: [:edit, :update]
  before_action :signed_in_user, only: [:index, :edit, :update]
  before_action :admin_user,     only: :destroy
  before_action :restrict_registration, only: [:new, :create]
  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, only: [:create, :destroy, :edit, :update]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
  	@user = User.new
  end

  def show
    @user = User.find(params[:id])
    @posts = @user.posts.paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Callboard!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
      unless current_user?(user)
        user.destroy
        flash[:success] = "User deleted."
      end
    redirect_to users_url
  end




  private

      def user_params
        params.require(:user).permit(:name, :login, :email, :birthday,
         :address, :city, :state, :country, :zip, :password, :avatar)
      end

      def admin_user
        redirect_to(root_path) unless current_user.try(:admin?)
      end

      def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user)
      end

      def restrict_registration
        redirect_to root_url, notice: "You are already regsitered." if user_signed_in?
      end

end
