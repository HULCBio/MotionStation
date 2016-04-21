% MATLAB Report Generator
% Version 1.3 (R13SP1) 27-Dec-2002
%
% Report Generator関数
%   report          - 設定ファイルからレポートを生成
%   setedit         - 設定ファイルをグラフィカルに修正
%   compwiz         - コンポーネント作成ウィザード
%   rptlist         - パス上の全ての.rpt設定ファイルをリスト
%   rptconvert      - SGMLソースを希望する出力書式に変換
%   rptrelatedfiles - ファイルに関連するすべてのファイルの検索
%
% Formattingコンポーネント 
%   cfrcelltable    - セルテーブル(Cell Table)
%   cfrsection      - チャプタ－/サブセクション(Chapter/Subsection)
%   cfrimage        - イメージ(Image)
%   cfrlink         - リンク(Link)
%   cfrlist         - リスト(List)
%   cfrparagraph    - パラグラフ(Paragraph)
%   cfrtext         - テキスト(Text)
%   cfr_titlepage   - タイトルページ(Title Page)
%
% Handle Graphicsコンポーネント 
%   chgfigloop      - Figure "For"ループ
%   chgfigproptable - Figureプロパティテーブル
%   chgfigsnap      - Graphics Figureスナップショット
%   chgobjname      - グラフィックスオブジェクト名
%   chgproperty     - Handle Graphicsパラメータ
%
% Logical & Flow Controlコンポーネント 
%   cloelse         - <if> Else
%   cloelseif       - <if> Elseif
%   clothen         - <if> Then
%   clofor          - Forループ
%   cloif           - Logical If
%   clo_while       - Whileループ
%
% MATLABコンポーネント 
%   cmleval         - MATLAB表現を評価(evalの適用）
%   cmlvariable     - 変数を挿入
%   cml_ver         - MATLAB/Toolboxバージョン番号
%   cmlwhos         - 変数テーブル
%
% Report Generatorコンポーネント 
%   crg_comment     - コメント
%   crgempty        - 空のコンポーネント
%   crg_import_file - ファイルのインポート
%   crgnestset      - 設定ファイルをネスト形式にする
%   crg_halt_gen    - レポート生成の停止
%   crgtds          - 時刻/日付のスタンプ
%


%   Copyright 1997-2002 The MathWorks, Inc.





%   Copyright 1997-2002 The MathWorks, Inc.
