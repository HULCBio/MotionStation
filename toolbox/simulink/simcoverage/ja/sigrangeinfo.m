% SIGRANGEINFO - モデルオブジェクトの信号レンジ
%
%
% [MIN,MAX] = SIGRANGEINFO(DATA,BLOCK)は、cvdataカバレージオブジェクトDATA内
% のBLOCKに対する信号レンジを求めます。ブロックが複数出力をもつ場合は、それら
% は結合され、MINとMAXはベクトルになります。
%
% モデルオブジェクトを指定するBLOCKパラメータは、つぎの形式をもちます。
%
% BlockPath           - Simulinkブロックまたはモデルの絶対パス　
% BlockHandle         - Simulinkブロックまたはモデルのハンドル　
% SimulinkObj         - SimulinkオブジェクトAPIハンドル
% StateflowID         - Stateflow ID (1つづつ起動されたチャートのもの)
% StateflowObj        - StateflowオブジェクトAPIハンドル
% (1つづつ起動されたチャートからのもの) {BlockPath, sfID}    - Stateflowオブ
%  ジェクトのパスとそのチャートのインスタンスに含まれるオブジェクトのIDからな
%                                             るセル配列
% {BlockPath, sfObj}   - チャートに含まれるStateflowブロックとStateflow オブ
%                        ジェクトのAPIハンドルのパス
% {BlockPath, sfID}    - Stateflowオブジェクトのパスとそのチャートのインスタン
%                        スに含まれるオブジェクトのIDからなるセル配列
%
% [MIN,MAX] = SIGRANGEINFO(DATA,BLOCK,PORTIDX)は、信号レンジをSimulinkブロッ
% クBLOCKに対するPORTIDX出力端子数に制限します。
%


% Copyright 1990-2003 The MathWorks, Inc.
