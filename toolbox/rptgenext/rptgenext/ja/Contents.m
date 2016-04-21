% Simulink Report Generator
% Version 1.3 (R13SP1) 27-Dec-2002
%
% Report Generator 関数
%   report            - 設定ファイルからレポートを生成
%   setedit           - 設定ファイルエディタGUI
%   compwiz           - report generatorコンポーネント作成ウィザード
%   rptlist           - パス上の全ての.rptファイルのリストを出力
%   rptconvert        - SGMLソースを希望する出力形式に変換
%   rptrelatedfiles   - ファイルに関連する全てのファイルを求める
%
% Simulink コンポーネント
%   csl_blk_autotable - ブロック自動プロパティテーブル
%   cslsortblocklist  - ブロック実行順序
%   csl_blk_loop      - ブロックループ
%   csl_blk_proptable - ブロックプロパティテーブル
%   cslblockcount     - ブロックタイプカウント
%   csl_blk_bus       - ブロックタイプ: バス(Bus)
%   csl_blk_lookup    - ブロックタイプ: ルックアップテーブル
%   cslscopesnap      - ブロックタイプ: スコープスナップショット
%   csl_mdl_changelog - モデル変更ログ
%   csl_functions     - モデル関数
%   csl_mdl_loop      - モデルループ
%   csl_mdl_proptable - モデルプロパティテーブル
%   cslsim            - モデルシミュレーション
%   csl_variables     - モデル変数
%   csllinktarget     - オブジェクトリンクアンカー
%   cslsysname        - オブジェクト名
%   cslproperty       - オブジェクトプロパティ
%   csl_summ_table    - オブジェクト概要テーブル
%   csl_sig_loop      - シグナルループ
%   csl_sig_proptable - シグナルプロパティテーブル
%   cslfilter         - システムフィルタ
%   cslsyslist        - システム階層構造
%   csl_sys_loop      - システムループ
%   csl_sys_proptable - システムプロパティテーブル
%   cslsnapshot       - システムスナップショット
%
% Stateflow コンポーネント
%   csf_chart_loop    - チャートループ
%   csflinktarget     - オブジェクトリンクアンカー
%   csfobjname        - オブジェクト名
%   csf_obj_report    - オブジェクトレポート
%   csf_summ_table    - オブジェクト概要テーブル
%   csf_prop_table    - プロパティテーブル
%   csf_snapshot      - Stateflow スナップショット
%   csf_hier_loop     - Stateflow ループ
%
% 参考 RPTGEN



%   Copyright 1997-2002 The MathWorks, Inc.
