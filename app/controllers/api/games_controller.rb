class Api::GamesController < ApplicationController
  def index; end

  def create
    game = Game.new

    if game.save
      render json: game
    else
      render json: game.errors, status: :bad_request
    end
  end
end
