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

  def transcribe
    game = Game.find(game_params[:id])

    require 'google/cloud/speech'
    # サービスアカウントの接続情報を記したファイルのパスを環境変数に格納
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = File.expand_path('../../../../gcp_key.json', __FILE__)
    speech = Google::Cloud::Speech.speech

    audio_file = game_params[:voice]

    config = { language_code: 'ja-JP' } # 日本語に設定
    audio = { content: audio_file.read } # 文字起こししたいファイルの中身を渡す

    response = speech.recognize config: config, audio: audio

    result = {
      transcript: response.results.first.alternatives[0].transcript,
      confidence: response.results.first.alternatives[0].confidence
    }

    render json: result
  end

  private

  def game_params
    params.permit(:id, :voice)
  end
end
