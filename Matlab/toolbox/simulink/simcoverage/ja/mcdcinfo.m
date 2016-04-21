% TABLEINFO - モデルオブジェクトのデシジョンカバレージ情報
%
% COVERAGE = MCDCINFO(DATA, BLOCK)は、cvdataカバレージオブジェクトDATA内の
% BLOCKに対する条件カバレージを求めます。COVERAGEは、2要素ベクトルとして出力さ
% れます: [covered_cases total_cases].BLOCKに関する情報はDATAの一部でない場
% 合は、COVERAGEは空です。
%
% 解析されるモデルオブジェクトを指定するBLOCKパラメータは、つぎの形式で指定さ
% れます。
%
% BlockPath           - Simulinkブロックまたはモデルの絶対パス　
% BlockHandle         - Simulinkブロックまたはモデルのハンドル　
% SimulinkObj         - SimulinkオブジェクトAPIハンドル
% StateflowID         - Stateflow ID (1つづつ起動されたチャートのもの)
% StateflowObj        - StateflowオブジェクトAPIハンドル
% (1つづつ起動されたチャートからのもの)
%  {BlockPath, sfID}    - Stateflowオブジェクトのパスとそのチャートのインス
%                         タンスに含まれるオブジェクトのIDからなるセル配列
% {BlockPath, sfObj}   - チャートに含まれるStateflowブロックとStateflow オブ
%                        ジェクトのAPIハンドルのパス
% {BlockPath, sfID}    - Stateflowオブジェクトのパスとそのチャートのインスタン
%                        スに含まれるオブジェクトのIDからなるセル配列
%
% COVERAGE = MCDCINFO(DATA, BLOCK, IGNORE_DESCENDENTS)は、BLOCKのデシジョン
% カバレージを求め、IGNORE_DESCENDENTSが真である場合に下層オブジェクト内のカ
%
% [COVERAGE,DESCRIPTION] = MCDCINFO(DATA, BLOCK)は、カバレージを求め、各ブーリ
% アン式のテキスト記述と、その式内の条件と、各条件が式の結果を個別に変更する
% ために実行されたかどうかを示すフラグ、Trueの結果に達した条件値を表わす文字
% 列と、falseの結果の文字列を含む構造体配列DESCRIPTIONを生成します。
%


% Copyright 1990-2003 The MathWorks, Inc.
