class TasksController < ApplicationController
  require 'json'
  before_action :login_req

  def new
    @user = User.find(session[:user_id])
  end

  def create
    @user = User.find(params[:user_id])
    tasks = task_params
    tasks[:current_value] = 0
    #Mahesh Starts
    if(tasks[:measure]=='Custom')
      if(tasks[:custom_measure]==nil)
        flash[:error] = "Custom Measure must be filled as measure is Custom"
        redirect_to new_user_task_path(@user)
        #show error
      else
        tasks[:measure]=tasks[:custom_measure]
      end
    end
    tasks.delete(:custom_measure)
    #Mahesh ends
    @tasks = @user.tasks.new(tasks)
    if @tasks.save
      redirect_to users_path
    else
      flash[:error] = "Invalid fields #{@tasks.errors.full_messages}"
      redirect_to new_user_task_path(@user)
    end
  end

  def show
    @user = User.find(session[:user_id])
    @task = @user.tasks.find(params[:id])
    @percent = (@task.current_value*100)/@task.target_value
    @timers = @task.timers.all
    rem = 0
    @sec = 0
    @timers.each do |time|
      @sec += time.seconds+(60*time.minutes)+(60*60*time.hours)
    end
  end

  def update_task
    @user = User.find(params[:user_id])
    @task = @user.tasks.find(params[:id])
    @task.current_value = params[:task][:current_value].to_i
    @timer = @task.timers.new(JSON.parse(params[:task][:timer_val]))
    if !@timer.save or !@task.save
      flash[:error] = "Unable to update, please retry again"
    end
    redirect_to user_task_path(@user,@task)
  end

  def edit
    @user = User.find(params[:user_id])
    @task = @user.tasks.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @task = @user.tasks.find(params[:id])
    @task.update_attributes!(task_params)
    redirect_to user_task_path(@user,@task)
  end

  def destroy
    @user = User.find(params[:user_id])
    @task = @user.tasks.find(params[:id])
    @task.destroy
    flash[:success] = "Task Destroyed successfully"
    redirect_to users_path
  end

  protected
  def task_params
    params.require(:task).permit(:title, :email, :desc, :target_date, :target_value, :measure, :create_date,:custom_measure)
  end

  def login_req
    if session[:user_id]==nil
        redirect_to login_path
    end
  end
end
