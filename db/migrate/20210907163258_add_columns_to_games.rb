class AddColumnsToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :transcript, :string, after: :id, comment: "認識文字列"
    add_column :games, :confidence, :float, after: :transcript, comment: "認識精度"
  end
end
