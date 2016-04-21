% SIMSIZES   S-functionのサイズ設定に用いるユーティリティ
%
% SIMSIZES は、S-functionについて特定の情報を与えるためのM-ファイル
% S-functionで利用される補助関数です。この情報は、入力、出力、状態の数、および他
% のブロックの特性を含んでいます。
%
% 引数を指定しないで mdlInitializeSizes のはじめに SIMSIZES 関数が呼び出さ
% れると、この情報をSimulinkに与えます。たとえば、
%  たとえば、 sizes = simsizes;これは、以下の形式の初期化されていない構造体を
% 出力します。 sizes.NumContStates       % 連続状態数
% sizes.NumDiscStates       % 離散状態数                        sizes.
% NumOutputs             % 出力数
% sizes.NumInputs              % 入力数
% sizes.DirFeedthrough      % 直接フィードスルーフラグ           sizes.
% NumSampleTimes      % サンプル時間数
%
% 単一引数(前述したサイズ構造体)を指定して実行すると、SIMSIZESは、
% S-functionブロックがフラグ0(サイズ構造体の呼び出し)で呼び出されたときに、
% サイズ構造体を適切な配列に変換し、Simulinkに処理を返します。たとえば、
% sys = simsizes(sizes);
%
% 参考 : SFUNTMPL.


% Copyright 1990-2002 The MathWorks, Inc.
