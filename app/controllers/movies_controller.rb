class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.pluck("rating")

    #if 'refresh' button pressed, get checked ratings
    #else check if session[:checked] is set, else just use all ratings
    if params[:ratings]
      @checked = params[:ratings].keys
      session[:checked] = @checked
    elsif session[:checked]
      @checked = session[:checked]
    else
      @checked = @all_ratings
      session[:checked] = @checked
    end

    @checked.each do |rating|
      params[rating] = true
    end

    #if getting movies by sorting movie_title or release_date
    #check if session[:checked] is set
    if params[:sort]
      if session[:checked]
        @movies = Movie.where(:rating => session[:checked]).order(params[:sort])
      else
        @movies = Movie.order(params[:sort])
      end

      @sort = params[:sort]
      session[:sort] = @sort

    #else if get the movies by rating rilter
    #check if session[:sort] is set
    elsif params[:ratings]
      if session[:sort]
        @movies = Movie.where(:rating => @checked).order(session[:sort])
        params[:sort] = session[:sort]
      else
        @movies = Movie.where(:rating => @checked)
      end

      @sort = session[:sort]

    #if session has been started
    #render page accordingly
    elsif session[:started]
      if session[:checked] and session[:sort]
        @movies = Movie.where(:rating => session[:checked]).order(session[:sort])
        params[:sort] = session[:sort]
      elsif session[:checked]
        @movies = Movie.where(:rating => session[:checked])
      elsif session[:sort]
        @movies = Movie.order(session[:sort])
        params[:sort] = session[:sort]
      else
        @movies = Movie.all
      end

    else
      #start session
      session[:started] = true
      @movies = Movie.all
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
