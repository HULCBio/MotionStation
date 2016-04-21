% CTRB   可制御行列を計算
%
% CO = CTRB(A,B) は、可制御行列 [B AB A^2B ...] を出力します。
%
% CO = CTRB(SYS) は、(A,B,C,D) によって実現される状態空間モデル SYS の
% 可制御行列を計算します。これは、CTRB(sys.a,sys.b) と等価です。
%
% 状態空間モデル SYS の ND 配列に対して、CO は N+2 の次元をもつ配列で、
% ここで、CO(:,:,j1,...,jN) は、状態空間モデル SYS(:,:,j1,...,jN) の
% 可制御行列を含みます。 
%
% 参考 : CTRBF, SS.


%   Copyright 1986-2002 The MathWorks, Inc. 
