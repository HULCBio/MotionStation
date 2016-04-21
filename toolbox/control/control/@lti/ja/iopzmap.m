% IOPZMAP   LTIモデルの極-零点マップ
%
%
% IOPZMAP(SYS) は、LTIモデル SYS の各入力/出力チャンネルの極と零点を計算し、
% 複素平面内にプロットします。極は、x としてプロットされ、零点は、oとしてプロッ
% トされます。
%
% IOPZMAP(SYS1,SYS2,...) は、複数のLTIモデルSYS1,SYS2,... の極と零点を1つの
% プロット図上に表示します。つぎのようにして、各モデルに対して、別々のカラーを指
% 定することができます。 iopzmap(sys1,'r',sys2,'y',sys3,'g')
%
% 関数 SGRID あるいは ZGRID は、s あるいは z 平面に、一定の減衰比と固有周波数
% の線図をプロットするために使用されます。
%
% LTIモデルの配列 SYS に対して、IOPZMAP は、配列の各モデルの極と零点を、同一の
% ダイアグラム上にプロットします。
%
% 参考 : PZMAP, POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
