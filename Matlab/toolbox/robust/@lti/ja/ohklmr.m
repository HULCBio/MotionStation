% OHKLMR 最適ハンケルノルム近似 (不安定プラント)
%
% [SS_M,TOTBND,HSV] = OHKLMR(SS_,MRTYPE,IN)、または、
% [AM,BM,CM,DM,TOTBND,HSV] = OHKLMR(A,B,C,D,MRTYPE,IN) は、つぎのような
% 条件を満足する既知のプラントG(s)のハンケルモデル低次元化を実行します。
% 
% 誤差(Ghed(s) - G(s))の無限大ノルム <= 
%            G(s)のk+1からnまでのハンケル特異値の和の2倍
% 
% 平衡化は必要ありません。
%
%   mrtype = 1の場合、inは低次元化モデルの次数k。
%   mrtype = 2の場合、トータルの誤差が"in"より小さくなる低次元化モデルを
%                     算出。
%   mrtype = 3の場合、ハンケル特異値を表示し、次数kの入力を促します。
%                    (この場合、"in"を指定する必要はありません。)
%
% TOTBND = 誤差範囲, HSV = ハンケル特異値



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
