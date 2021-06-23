# すいませんチェッカー（タイトル検討中）

## サービス概要

飲食店で店員さんを呼ぶ声が中々届かない人向けに、
「すいません」という声の上手さを計測して、今後の改善に役立ててもらうためのサービスです。

## ユーザーが抱える課題

- 地声が小さいせいで、スマートに店員さんを呼ぶことができない。
- 必要以上に大きな声を出して、周りに不快な思いをさせてしまうことがある。

## 解決方法

- ちょうどいい声の大きさで店員を呼ぶゲームを通して、発声の練習を促します。
- ゲームはSTAGE1〜STAGE3まであり、それぞれが異なるシチュエーションです。
  シチュエーションによって最適な声の大きさが設定されているので、
  ユーザーはちょうどいい声の大きさで「すいませーん」と言います。
  ※シチュエーションの例：「図書館の受付」「大学近くのカフェ」「居酒屋」
- 声が大きすぎた場合、周りのお客さんが帰ってしまいます。
  逆に声が小さいと、店員さんが気付いてくれないため、再チャレンジとなります。
- 全ステージクリア後、「帰らせたお客さんの数」と、「チャレンジした回数」に基づいて、総合結果が表示されます。（どちらも少ない方がいい）
- 判定結果に応じて、メッセージを表示します。
  - 例1: (Goodパターン) 理想的なすいませんです。率先して店員さんを呼んであげてください。
  - 例2: (Badパターン) 店員さんを呼ぶのは諦めて、押しボタンのあるお店を選びましょう。
- 判定結果をTwitterに投稿できるようにします。
- チャレンジ回数が一定以上だった（＝声が小さい）場合、腹式呼吸や発声の練習ができる動画を提案します。

## プロダクト
ゲーム形式で声量の測定ができるWebアプリケーション

## マーケット
声が通らないことにコンプレックスを抱えている人
