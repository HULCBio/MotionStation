% OBSVF   可観測ステアケース型を作成
%
% [ABAR,BBAR,CBAR,T,K] = OBSVF(A,B,C) は、可観測/非可観測部の部分空間に
% 分解します。
%
% [ABAR,BBAR,CBAR,T,K] = OBSVF(A,B,C,TOL) は、トレランス TOL を使います。
%
% Ob = OBSV(A,C) が、rank r < =  n = SIZE(A,1) の場合、つぎのような相似
% 変換 T が存在します。
%
%   Abar = T * A * T' ,  Bbar = T * B  ,  Cbar = C * T'
%
% そして、変換されたシステムは、つぎのような型をしています。
%
%       | Ano   A12|           |Bno|
% Abar =  ----------  ,  Bbar =  ---  ,  Cbar = [ 0 | Co].
%       |  0    Ao |           |Bo |
%                                                        
% ここで、(Ao,Bo) は可制御で、つぎの関係が成り立ちます。
%          -1          -1
% Co(sI-Ao) Bo = C(sI-A) B
% 
% 最新の出力 K は、アルゴリズムの各繰り返しで識別される可観測な状態の数
% を要素とした長さ n のベクトルです。可観測な状態数は、SUM(K) です。
%
% 参考：    OBSV, CTRBF.


%   Author : R.Y. Chiang  3-21-86
%   Revised 5-27-86 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:37 $
