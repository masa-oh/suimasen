class Game < ApplicationRecord
  include IdGenerator

  has_many :stages

  def transcribe(audio_file)
    require 'google/cloud/speech'
    # サービスアカウントの接続情報を記したファイルのパスを環境変数に格納
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = File.expand_path('../../../config/gcp_key.json', __FILE__)
    speech = Google::Cloud::Speech.speech

    config = { language_code: 'ja-JP' } # 日本語に設定
    audio = { content: audio_file.read } # 文字起こししたいファイルの中身を渡す

    # APIを叩いて、結果を受け取る
    response = speech.recognize config: config, audio: audio

    self.transcript = response.results.present? ? response.results.first.alternatives[0].transcript : ''
    self.confidence = response.results.present? ? response.results.first.alternatives[0].confidence : 0
  end
end
