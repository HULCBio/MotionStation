% Fuzzy Logic Toolbox
% Version 2.1.3 (R14) 05-May-2004
%
% GUI エディタ
% anfisedit  - ANFIS 訓練と検証用のUIツール
% findcluster- クラスタリング UI ツール
% fuzzy      - 基本のFISエディタ
% mfedit     - メンバシップ関数エディタ
% ruleedit   - ルールエディタと文法の使い方
% ruleview   - ルールビューアとファジィ推論ダイアグラム
% surfview   - 出力サーフェスビューア
%
% メンバシップ関数
% dsigmf     - 2つのシグモイドメンバシップ関数の差
% gauss2mf   - 2つのガウス曲線を合わせたメンバシップ関数
% gaussmf    - ガウス曲線メンバシップ関数
% gbellmf    - 一般化されたベル曲線メンバシップ関数
% pimf       - π型曲線メンバシップ関数
% psigmf     - 2つのシグモイドメンバシップ関数の積
% smf        - S型曲線メンバシップ関数
% sigmf      - シグモイド曲線メンバシップ関数
% trapmf     - 台形メンバシップ関数
% trimf      - 三角形メンバシップ関数
% zmf        - Z型曲線メンバシップ関数
%
% コマンドラインFIS関数
% addmf      - メンバシップ関数をFISに追加
% addrule    - ルールを FIS に追加
% addvar     - 変数を FIS に追加
% defuzz     - メンバシップ関数の非ファジィ化
% evalfis    - ファジィ推論計算の実行
% evalmf     - 基本的なメンバシップ関数計算
% gensurf    - FIS 出力サーフェスの計算
% getfis     - ファジィシステムプロパティの取得
% mf2mf      - 関数間でのパラメータの変換
% newfis     - 新しい FIS の作成
% parsrule   - ファジィルールの文法説明
% plotfis    - FIS の入力－出力ダイアグラムの表示
% plotmf     - 1つの変数に依存するすべてのメンバシップ関数の表示
% readfis    - ディスクから FIS の読み込み
% rmmf       - メンバシップ関数を FIS から削除
% rmvar      - 変数を FIS から削除
% setfis     - ファジィシステムプロパティの設定
% showfis    - 注釈付きで FIS の表示
% showrule   - FIS ルールの表示
% writefis   - FIS をディスクに保存
%
% アドバンスト手法
% anfis      - 菅野タイプの FIS の訓練ルーチン (MEX のみ)
% fcm        - ファジィ c-means クラスタリングを用いたクラスタの検出
% genfis1    - 一般的な手法による FIS 行列の作成
% genfis2    - 抽出クラスタリングを用いた FIS 行列の作成
% subclust   - 抽出クラスタリングを用いたクラスタセンタの検出
%
% その他の関数
% convertfis - v1.0ファジィ行列からv2.0ファジィ構造体への変換
% discfis    - ファジィ推論システムの離散化
% evalmmf    - 複数のメンバシップ関数の評価
% fstrvcat   - 様々なサイズの行列の連結
% fuzarith   - ファジィ演算関数
% findrow    - 入力文字列と一致する行を行列から検出
% genparam   - ANFIS 学習のための初期の前件パラメータの作成
% probor     - 確率的 OR
% sugmax     - 菅野システムの最大出力範囲
%
% GUI補助関数
% cmfdlg     - カスタマイズされたメンバシップ関数を追加するダイアログ
% cmthdlg    - カスタマイズされた推論方法を追加するダイアログ
% fisgui     - Fuzzy Logic Toolbox の一般的なGUIのハンドリング
% gfmfdlg    - グリッドによる区切り法を使った FIS の設計ダイアログ
% mfdlg      - メンバシップ関数を追加するダイアログ
% mfdrag     - マウスを使ったメンバシップ関数のドラッグ
% popundo    - 最後の FIS 変更の取り消しスタックからのポップオフ
% pushundo   - カレントの FIS の取り消しスタックへのプッシュ
% savedlg    - ダイアログを閉じる前に保存
% statmsg    - ステータスフィールドへのメッセージの表示
% updtfis    - Fuzzy Logic Toolbox GUI ツールの更新
% wsdlg      - ワークスペースにデータを読み込んだり、データをセーブする
%              ダイアログのオープン


%   Copyright 1994-2004 The MathWorks, Inc.



