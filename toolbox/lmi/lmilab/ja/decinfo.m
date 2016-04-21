% decinfo(lmisys)
% decX = decinfo(lmisys,X)
%
% 行列変数の構造と、その要素の決定変数x1,...,xN(LMI問題の中のスカラの自
% 由変数)との関係を表示します。
%
% 行列変数Xの中の要素x1,...,xNは、つぎのような用法の整数行列DECXによって
% 記述されます。
%    DECX(i,j)=0   は、X(i,j)がゼロであることを意味します。
%    DECX(i,j)=n   は、X(i,j) = xn (n番目の決定変数)を意味します。
%    DECX(i,j)=-n  は、X(i,j) = -xnを意味します。
%
% 入力引数を1つだけ設定して実行すると、DECINFOは、インタラクティブな質問
% /答えの環境になります。
%
% 入力:
%   LMISYS     LMIシステムの内部記述
%   X          注目する変数行列の識別子(LMIVARを参照)
% 出力:
%   DECX       x1,...,xNに対するXの要素単位の関係 
%
% 参考：    DECNBR, DEC2MAT, MAT2DEC, LMIVAR.



% Copyright 1995-2002 The MathWorks, Inc. 
