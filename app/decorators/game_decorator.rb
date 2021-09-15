class GameDecorator < ApplicationDecorator
  delegate_all

  def score
    pattern = /すいません|すみません/
    object.transcript&.match(pattern) ? object.confidence.to_i : 0
  end
end
