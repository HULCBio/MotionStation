% Simulink Model Coverage Tool
%
%
% モデルの範囲を設定する関数
% cvtest           - cvtest オブジェクトの作成
% cvdata           - 整数 ID を cvdata オブジェクトに変換
% cvload           - ファイルから coverage データをロード
% cvsave           - coverage データをファイルに保存
% cvsim            - coverage instrumented シミュレーションを実行
% cvreport         - cvdata オブジェクトのテキストレポートを作成
% cvhtml           - cvdata オブジェクトのHTMLレポートの作成
% cvmodelview          - カラリングを用いたモデルのカバレージデータの表示
% cvenable         - Simulink モデルの可能なcovarage
% cvexit           - Coverage 環境の終了 cvresolve        - Simulink にリン
%                    クしている Coverage ツールの更新
% cvclean          - モデルに関連するcoverageデータの割り当てを解除
%
% データ検索関数
% conditioninfo    - モデルオブジェクトに対するdecision coverage情報
% decisioninfo     - モデルオブジェクトに対するcondition coverage情報
% mcdcinfo         - モデルオブジェクトに対する MCDC 情報
% tableinfo        - モデルオブジェクトに対するルックアップテーブルcoverag
%                    e情報
% sigrangeinfo         - モデルオブジェクトに対する信号の範囲
%
% デモファイル
% simcovdemo       - モデルカバレージのコマンドラインデモ
% ratelim_harness  - simcovdemo で使われるモデル
%
% cvdataオブジェクトのオーバロードされた算術演算
% cvdata/times - (*) - 2つの cvdata 間のcoverageの積集合の検出
% cvdata/times - (*) - 2つの cvdata 間のcoverageの積集合の検出
% cvdata/times - (*) - 2つの cvdata 間のcoverageの積集合の検出
%
%


% Copyright 1990-2003 The MathWorks, Inc.
