class MusicsController < ApplicationController
  before_action :set_music, only: [:show, :edit, :update, :destroy]
  before_action :all_musics, only: [:index, :create]
  respond_to :html, :js

  # GET /musics
  # GET /musics.json
  # def index
  #   current_user = User.find(session[:user_id])
  #   @musics = current_user.discover_musics

  #   respond_to do |format|
  #     format.html
  #     format.js
  #   end
  
  # end

  # GET /musics/1
  # GET /musics/1.json
  def show  
     # @user = User.where(session[:user_id] => params[:uid])
  end

  # GET /musics/new
  def new
    @music = Music.new
  end

  # GET /musics/1/edit
  def edit
  end



  # POST /musics
  # POST /musics.json
  def create
    @music = Music.new(music_params)

    @music.uid = session[:user_id]

    respond_to do |format|
      if @music.save
        format.html { redirect_to @music, notice: 'Music was successfully created.' }
        # format.html { redirect_to @musics_url }
        format.json { render action: 'show', status: :created, location: @music }
      else
        format.html { render action: 'new' }
        format.json { render json: @music.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /musics/1
  # PATCH/PUT /musics/1.json
  def update
    respond_to do |format|
      if @music.update(music_params)
        format.html { redirect_to @music, notice: 'Music was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @music.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /musics/1
  # DELETE /musics/1.json
  def destroy
    @music.destroy
    respond_to do |format|
      format.html { redirect_to musics_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_music
      @music = Music.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def music_params
      params.require(:music).permit( :comment, :link, :uid)
    end

    def all_musics
      current_user = User.find(session[:user_id])
      @musics = current_user.discover_musics
    end
end
