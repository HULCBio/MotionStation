% DNICHOLS   離散時間線形システムに対する Nichols周波数応答
%
% DNICHOLS(A,B,C,D,Ts,IU) は、離散状態空間システム (A, B, C, D) の単入力 
% IU からすべての出力への Nichols線図を作成します。IU は、システムの
% 入力の中から Nichols応答を計算するために使用する入力を選択するための
% インデックスです。Ts はサンプル周期です。周波数の範囲と点数は、自動的に
% 決められます。
%
% DNICHOLS(NUM,DEN,Ts) は、多項式伝達関数 G(z) = NUM(z)/DEN(z) に対する 
% Nichols線図を作成します。ここで、NUM と DEN は、多項式の係数を z の
% 降ベキの順に並べたものです。
%
% DNICHOLS(A,B,C,D,Ts,IU,W) または、DNICHOLS(NUM,DEN,Ts,W) は、Nichols応答
% を計算する周波数を rad/sec 単位でユーザが設定した周波数ベクトル W を
% 使用します。エリアジングは、Nyquist周波数(pi/Ts)より高い周波数で生じます。
% 左辺の引数を設定しない場合、
% 
%            [MAG,PHASE,W] = DNICHOLS(A,B,C,D,Ts,...)
%            [MAG,PHASE,W] = DNICHOLS(NUM,DEN,Ts,...) 
% 
% 周波数ベクトル W と行列 MAG と PHASE(単位度)を出力します。これらは、
% 出力と同じ列数をもち、length(W) と等しい行数をもっています。スクリーン上
% にプロット表示は行われません。Nichols グリッドは、NGRID を使って描く
% ことができます。 
%
% 参考 : LOGSPACE, SEMILOGX, MARGIN, DBODE, DNYQUIST.


%       Clay M. Thompson 7-10-90
%       Revised ACWG 2-12-91, 6-21-92
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:52 $
