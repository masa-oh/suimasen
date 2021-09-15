class Api::GamesController < ApplicationController
  def index; end

  def create
    game = Game.new
    
    game.transcribe(game_params[:voice])

    if game.save
      render json: game
    else
      render json: game.errors, status: :bad_request
    end
  end

  private

  def game_params
    params.permit(:voice)
  end
end
