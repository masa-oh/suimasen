module ApplicationHelper
  def default_meta_tags
    {
      title:       "すいませんチェッカー - 店員さん、呼べてますか？",
      description: "周りの音にかき消されない\"通る声\"を手に入れよう。すいませんチェッカーは、店員さんを呼ぶ声が中々届かない人のための、音声測定・発声改善支援サービスです。",
      keywords:    "すいません,すみません,声が小さい",
      noindex: !Rails.env.production?, # production環境以外はnoindex
      canonical: request.original_url,  # 優先されるurl
      charset: "UTF-8",
      og: {
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("suimasen_ogp.png"),
        site_name: "すいませんチェッカー",
        locale: "ja_JP"
      },
      twitter: {
        creator: '@m_asa_o',
        card: 'summary_large_image',
        image: image_url("suimasen_ogp.png") # ツイッター専用にイメージを設定する場合
      },
    }
  end
end
