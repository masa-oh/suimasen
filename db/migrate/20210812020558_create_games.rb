class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games, id: false, comment: 'ゲーム' do |t|
      t.string :id, limit: 36, null: false, primary_key: true, comment: 'ID'

      t.timestamps
    end
  end
end
