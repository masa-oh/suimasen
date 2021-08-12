class Api::GamesController < ApplicationController
  def index; end

  def create
    @spectrums = []
    params.require(:spectrums).each{|spectrum|
      permitted = spectrums_permit(record)
      @spectrums.push(permitted)
    }
    render json: @spectrums[0]
  end

  private

  def test_params
    params.require(:spectrums)
  end
end
