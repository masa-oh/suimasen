class Game < ApplicationRecord
  include IdGenerator

  has_many :stages
end
