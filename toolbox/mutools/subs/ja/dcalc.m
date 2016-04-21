% function  d = dcalc(b,c,sig,q)
%
% (C(sI-A)^(-1)B+D)のL∞ノルムがsig(1)+...+sig(n)より小さいようなD行列を
% 計算します。BとC は、n個の状態量をもつ平衡化実現からの出力で、SIGは
% Hankel特異値からなるベクトルです。Qは、システムが組み込まれる次元です。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:43 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
