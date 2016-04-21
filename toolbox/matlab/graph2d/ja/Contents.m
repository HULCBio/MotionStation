% 2次元グラフ
% 
% 基本的な X-Yグラフ
% plot      - 線形プロット
% loglog    - 両対数スケールプロット
% semilogx  - 片対数スケールプロット
% semilogy  - 片対数スケールプロット
% polar     - 極座標プロット
% plotyy    - 左右両側にy軸をもつグラフ
%
% 軸の制御
% axis       - 軸のスケーリングと外観の制御
% zoom       - 2次元プロットのズームインとズームアウト
% grid       - グリッドライン
% box        - 軸の型
% hold       - カレントグラフのホールド
% axes       - 任意の位置にaxesを作成
% subplot    - 複数のaxesの作成
%
% グラフの注釈
% plotedit  - プロットの編集と注釈付けのためのツール
% title     - グラフのタイトル
% xlabel    - X軸のラベル
% ylabel    - Y軸のラベル
% texlabel  - キャラクタ文字列からTeXフォーマットを作成
% text      - 注釈のテキスト
% gtext     - マウスを使ってテキストを配置
%
% ハードコピーと印刷
% print     - グラフやSimulinkシステムの印刷、またはM-ファイルにグラフを
%             保存
% printopt  - プリンタのデフォルト
% orient    - 用紙の方向の設定
%
% 参考： GRAPH3D, SPECGRAPH.
%
% ユーティリティ
% lscan     - 凡例の適切な位置を探してスキャン
% moveaxis  - legend axis をとらえて移動
%
% Scribe utilties.
%   doclick       - ML オブジェクトの ButtonDown 処理
%   dokeypress    - キープレス関数の処理
%   domymenu      - Handle コンテキストメニュー
%   doresize      - figobj doresize 関数の呼び出し
%   enddrag       - プロットエディタ補助関数
%   getobj        - HG ハンドルから Scribe オブジェクトを取得
%   middrag       - プロットエディタ補助関数
%   prepdrag      - プロットエディタ補助関数
%   putdowntext   - プロットエディタ補助関数
%   scribeaxesdlg - Axes プロパティダイアログ補助関数
%   scribelinedlg - Line プロパティダイアログ補助関数
%   scribeclearmode       - プロットエディタ補助関数
%   scribeeventhandler    - プロットエディタ補助関数
%   scriberestoresavefcns - プロットエディタ補助関数
%   scribetextdlg - プロットエディタでTextとFontのプロパティを編集

%   Copyright 1984-2002 The MathWorks, Inc.
