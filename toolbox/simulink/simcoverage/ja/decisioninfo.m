% DECISIONINFO - モデルオブジェクトのデシジョンカバレージ情報
%
% COVERAGE = DECISIONINFO(DATA, BLOCK)は、cvdataカバレージオブジェクトDATA内
% のBLOCKのデシジョンカバレージを求めます。COVERAGEは、2要素ベクトルとして出力
% されます。 [covered_outcomes total_outcomes].
% BLOCKに関する情報はDATAの一部でない場合は、COVERAGEは空です。
%
% モデルオブジェクトを指定するBLOCKパラメータは、つぎの形式です。
%
% BlockPath           - Simulinkブロックまたはモデルの絶対パス
% BlockHandle         - Simulinkブロックまたはモデルのハンドル
% SimulinkObj         - SimulinkオブジェクトAPIハンドル
% StateflowID         - Stateflow ID (1つづつ起動されたチャートのもの) Sta
%                       teflowObj        - StateflowオブジェクトAPIハンドル
% (1つづつ起動されたチャートからのもの)
% {BlockPath, sfID}    - Stateflowオブジェクトのパスとそのチャートのインスタン
%                        スに含まれるオブジェクトのIDからなるセル配列
% {BlockPath, sfObj}   - チャートに含まれるStateflowブロックとStateflowオブ
%                        ジェクトのAPIハンドルのパス
% {BlockPath, sfID}    - Stateflowオブジェクトのパスとそのチャートのインスタン
%                        スに含まれるオブジェクトのIDからなるセル配列
%
% COVERAGE = DECISIONINFO(DATA, BLOCK, IGNORE_DESCENDENTS)は、カバレージを求
% め、IGNORE_DESCENDENTSは真である場合に下層オブジェクト内のカバレージを無視
%
% [COVERAGE,DESCRIPTION] = DECISIONINFO(DATA, BLOCK)?は、カバレージを求め、
% BLOCK内のデシジョンの構造的な記述と条件を生成します。DESCRIPTIONは、各デシ
% ジョンのテキスト記述と、BLOCK内の各結果に対する記述と、実行カウントを含む構
% 造体です。
%


% Copyright 1990-2003 The MathWorks, Inc.
