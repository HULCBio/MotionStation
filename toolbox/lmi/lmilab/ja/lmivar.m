% X = lmivar(type,struct)
% [X,ndec,Xdec] = lmivar(type,struct)
%
% カレントに記述されている連立LMIに、新しい行列変数Xを追加します。ラベル
% Xは、この新しい変数を後で参照するときに利用するために、オプションで付
% 加されます。
%
% 入力:
%  TYPE     Xの構造:
%		  1 -> ブロック対角構造をもつ対称行列
%		  2 -> フル長方行列
%		  3 -> その他の構造
%  STRUCT   Xの構造に付加するデータ
%        TYPE=1: STRUCTのi番目の行は、Xのi番目の対角ブロックを記述します。
%                STRUCT(i,1) -> ブロックサイズ
%                STRUCT(i,2) -> ブロックタイプ。すなわち
%                                   0  スカラブロックt*I
%                                   1  フルブロック
%                                   -1 ゼロブロック
%        TYPE=2: XがM行N列行列ならば、STRUCT = [M,N]。
%        TYPE=3: STRUCTは、Xと同じ次元の行列です。
%                ここで、STRUCT(i,j)は、つぎのいずれかです。
%                    X(i,j) = 0のとき、0
%                    X(i,j) = n番目の決定変数のとき、+n
%                    X(i,j) = (-1)* n番目の決定変数のとき、-n
% 出力:
%  X        オプション: 新規の行列変数に対する識別子。
%           k-1個の行列変数がすでに宣言されていれば、その値はkとなります。
%           この識別子は、LMIの変更によって影響を受けません。
%  NDEC     決定変数の総数。
%  XDEC     Xの要素単位の決定変数との関係(Xdec = Type 3に対する構造)。
%
% 参考：    SETLMIS, LMITERM, GETLMIS, LMIEDIT, DECINFO.



% Copyright 1995-2002 The MathWorks, Inc. 
