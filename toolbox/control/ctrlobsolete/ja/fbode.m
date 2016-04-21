% FBODE   連続時間線形システムに対する Bode 周波数応答
%
% FBODE(A,B,C,D,IU) は、単入力 IU から連続状態空間システム(A, B, C, D)の
% すべての出力に対する Bode プロットを作成します。IU は、Bode 応答に使用
% する入力を指定する入力のインデックスです。周波数帯域と点数は、自動的に
% 選択されます。FBODE は、BODE より高速ですが、精度が下がります。
%
% FBODE(NUM,DEN) は、多項式伝達関数 G(s) = NUM(s)/DEN(s) に対する Bode 
% 線図を作成します。ここで、NUM と DEN は、s で表した降ベキの順に並べた
% 多項式係数を含んでいます。
%
% FBODE(A,B,C,D,IU,W) または、FBODE(NUM,DEN,W) は、ユーザ指定の周波数
% ベクトル W を使います。このベクトルは、rad/sec 単位で、Bode 応答を計算
% する位置を表します。対数間隔の周波数ベクトルを作成するには、LOGSPACE を
% 参照してください。つぎのように、
%
% 		[MAG,PHASE,W] = FBODE(A,B,C,D,...)
%		[MAG,PHASE,W] = FBODE(NUM,DEN,...) 
%
% 左辺に引数を設定すると、周波数ベクトル W と行列 MAG と PHASE(単位は度)
% を出力します。この行列は、length(W) 行をもちます。また、このステート
% メントでは、スクリーン上にプロットを表示しません。
%
% 参考 : LOGSPACE,SEMILOGX,MARGIN, BODE.


% 	J.N. Little 12-5-88
%	Revised CMT 8-2-90, ACWG 6-21-92
%	Revised A.Potvin 10-1-94
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:00 $
