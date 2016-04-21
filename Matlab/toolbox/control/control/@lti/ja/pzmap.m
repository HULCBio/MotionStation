% PZMAP   LTIモデルの極-零点の配置図
%
% PZMAP(SYS) は、LTIモデル SYS の極と(伝達)零点を求め、複素平面にプロット
% します。極は x で、零点は o でプロットします。
% 
% PZMAP(SYS1,SYS2,...) は、複数のLTIモデル SYS1,SYS2,...の極と零点を一つの
% プロット図上に表示します。ユーザは、各モデルに対して、別々なカラーを
% つぎのようにして設定できます。
% 
%   pzmap(sys1,'r',sys2,'y',sys3,'g')   
% 
% 左辺に出力引数を指定した場合、[P,Z] = PZMAP(SYS) は、システムの極と
% 零点を列ベクトル P と Z で出力します。画面にはプロットしません。 
%
% 関数 SGRID または ZGRID を用いて、減衰率および固有周波数をs平面または
% z平面にプロットすることができます。
%
% LTIモデルの配列 SYS に対して、PZMAP は配列の各モデル毎の極と零点を同じ
% ダイアグラム上にプロットします。
%
% 参考 : POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.


%	Clay M. Thompson  7-12-90
%	Revised ACWG 6-21-92, AFP 12-1-95, PG 5-10-96, ADV 6-16-00
%          Kamesh Subbarao 10-29-2001
%	Copyright 1986-2002 The MathWorks, Inc. 
