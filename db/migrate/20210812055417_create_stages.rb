class CreateStages < ActiveRecord::Migration[6.0]
  def change
    create_table :stages, comment: 'ステージ' do |t|
      t.references :game, type: :string, foreign_key: true
      t.integer :score, comment: '得点'

      t.timestamps
    end
  end
end
