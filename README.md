# すいませんチェッカー

[![Rails](https://img.shields.io/badge/Rails-v6.0.4.1-CC0000)](https://rubygems.org/gems/rails/versions/6.0.4.1)
[![Vue](https://img.shields.io/badge/Vue-v2.6.11-%2342b77c)](https://www.npmjs.com/package/vue/v/2.6.11)

周りの音にかき消されない"通る声"を手に入れよう。<br/>
すいませんチェッカーは、店員さんを呼ぶ声が中々届かない人のための、音声測定・発声改善支援サービスです。

**https://suimasen.jp/**

![suimasen_ogp](https://github.com/masa-oh/suimasen/blob/develop/app/assets/images/suimasen_ogp.png)

## サービス概要
- このサービスは、「すいません」という声が店員さんに届くかどうかを測定するゲームです。
- ステージごとに異なる騒音の中で、無事店員さんに「すいません」と聞き取ってもらうことができたらクリアとなります。

## 使用技術

### バックエンド
- Ruby 3.0.0
- Rails 6.0.4

### フロントエンド
- Vue 2.6.11
- Vuetify 2.5.8
- JavaScript

### その他
#### ブラウザAPI
- Web Speech API（リアルタイム文字起こし）
- MediaStream Recording API（録音）
- Web Audio API（音声合成、音量調節）

#### 外部API
- Google Cloud Speech-to-Text API（文字起こし）

## ユーザーが抱える課題

- 地声が小さいせいで、スマートに店員さんを呼ぶことができない。（声質の問題）
- 声が届かないことによるトラウマや緊張で、なおさら声が小さくなってしまっている。（潜在意識の問題）

## 課題に対するアプローチ

### 声質改善
- 実際の騒音の中で店員さんを呼ぶ声がどのように聞こえるかを再現する。
- 声質改善に役立つYouTube動画を提案する。

→ ユーザーは自分の声がどう聞こえにくいのかを把握しながら、効果的に改善することができる。

### 潜在意識の回復
- ゲーム形式で繰り返し楽しく練習ができる、というコンセプトに基づいて設計している。

→ ユーザーは繰り返し自らの声を聞くことで、自分の声は通らないという認知の歪みを徐々に取り除くことができる。

## プロダクト
ゲーム形式で「すいません」の上手さの測定ができるWebアプリケーション

## マーケット
声が通らないことにコンプレックスを抱えている人

## 画面遷移図（figma）
https://www.figma.com/file/OQPbdKwrIdjaPgf8wXFsLY/%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0%3A1

## テーブル設計（ER図、IE記法）
https://drive.google.com/file/d/19KtQLw_2r1E6WqfVbGpGK66XkacDRnwz/view?usp=sharing
