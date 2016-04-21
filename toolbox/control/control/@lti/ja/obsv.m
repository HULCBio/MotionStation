% OBSV   可観測行列の計算
%
% OB = OBSV(A,C) は、可観測行列 [C; CA; CA^2 ...] を出力します。
%
% CO = OBSV(SYS) は、(A,B,C,D) で実現される状態空間モデル SYS の可観測
% 行列を出力します。これは、OBSV(sys.a, sys.c) と等価です。
%
% 状態空間モデル SYS の ND 配列に対して、OB は N+2 の次元をもつ配列です。
% ここで、OB(:,:,j1,...,jN) は、状態空間モデル SYS(:,:,j1,...,jN) の可観測
% 行列を含みます。
%
% 参考 : OBSVF, SS.


%   Copyright 1986-2002 The MathWorks, Inc. 
