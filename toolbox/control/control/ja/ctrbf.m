% CTRBF   可制御性ステアケース型を出力
%
% [ABAR,BBAR,CBAR,T,K] = CTRBF(A,B,C) は、可制御性/非可制御性の部分空間
% に分解します。
%
% [ABAR,BBAR,CBAR,T,K] = CTRBF(A,B,C,TOL) は、トレランス TOL を使用します。
%
% Co = CTRB(A,B) が、ランク r < =  n = SIZE(A,1) の場合、つぎのような
% 相似変換 T が存在します。
%
%   Abar = T * A * T' ,  Bbar = T * B ,  Cbar = C * T'
%
% そして、変換されたシステムは、つぎのような型をしています。
%
%          | Anc    0 |           | 0 |
%   Abar =  ----------  ,  Bbar =  ---  ,  Cbar = [Cnc| Cc].
%          | A21   Ac |           |Bc |
%                                                 -1          -1
% ここで、(Ac,Bc) は可制御で、つぎの関係、Cc(sI-Ac) Bc = C(sI-A) B が成
% り立ちます。
% 
% 最新の出力 K は、アルゴリズムの各繰り返しで識別される可制御な状態の数
% を要素とした長さ n のベクトルです。可制御な状態数は、SUM(K) です。
%
% 参考：CTRB, OBSVF.


%   Author : R.Y. Chiang  3-21-86
%   Revised 5-27-86 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:03:55 $
