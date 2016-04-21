% DBODE   離散時間線形システムに対する Bode 周波数応答
%
% DBODE(A,B,C,D,Ts,IU) は、単入力 IU から離散状態空間システム(A, B, C, D)
% のすべての出力に対する Bode プロットを作成します。IU は、Bode 応答に
% 使用する入力を指定する入力のインデックスです。Ts は、サンプル周期です。
% 周波数帯域と点数は、自動的に選択されます。
%
% DBODE(NUM,DEN,Ts) は、多項式伝達関数 G(z) = NUM(z)/DEN(z) に対する 
% Bode 線図を作成します。ここで、NUM と DEN は、z で表した降ベキの順に
% 並べた多項式係数を含んでいます。
%
% DBODE(A,B,C,D,Ts,IU,W) または、DBODE(NUM,DEN,Ts,W) は、ユーザ指定の
% 周波数ベクトル W を使います。このベクトルは、rad/sec 単位で、Bode 応答を
% 計算する位置を表します。エリアジングは、Nyquist 周波数(pi/T)以上の周波数で
% 生じます。対数間隔の周波数ベクトルを作成するには、LOGSPACE を参照して
% ください。つぎのように、
% 
%    [MAG,PHASE,W] = DBODE(A,B,C,D,Ts,...)
%    [MAG,PHASE,W] = DBODE(NUM,DEN,Ts,...) 
% 
% 左辺に引数を設定すると、周波数ベクトル W と行列 MAG と PHASE(単位は度)を
% 出力します。この行列は、length(W) 行をもちます。また、このステートメント
% では、スクリーン上にプロットを表示しません。
%
% 参考 : BODE, LOGSPACE, SEMILOGX, MARGIN, NICHOLS, NYQUIST.


%   J.N. Little 10-11-85
%   Revised Andy Grace 8-15-89 2-4-91 6-20-92
%   Revised Clay M. Thompson 7-10-90
%   Revised A.Potvin 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:35 $
