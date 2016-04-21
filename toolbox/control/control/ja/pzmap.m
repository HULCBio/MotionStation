% PZMAP   LTI モデルの極-零点の配置図
%
%
% PZMAP(SYS) は、LTI モデル SYS の極と(伝達)零点を求め、複素平面にプロット
% します。極は x で、零点は o でプロットします。
%
% PZMAP(SYS1,SYS2,...) は、複数の LTI モデル SYS1,SYS2,...の極と零点を一つの
% プロット図上に表示します。ユーザは、各モデルに対して、別々なカラーをつぎの
% ようにして設定できます。 
%   pzmap(sys1,'r',sys2,'y',sys3,'g')
%
% [P,Z] = PZMAP(SYS) は、システムの極と零点を2つの列ベクトル P と Z に出力
% します。画面にはプロットは表示されません。
%
% 関数 SGRID または ZGRID を用いて、減衰率および固有周波数を s 平面または
% z 平面にプロットすることができます。
%
% LTI モデルの配列 SYS に対して、PZMAP は配列の各モデル毎の極と零点を同じダ
% イアグラム上にプロットします。
%
% 参考 : POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
