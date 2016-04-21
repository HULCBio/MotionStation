% CONVMTX2   2次元のコンボリューション行列を計算
% T = CONVMTX2(H,M,N)、または、T = CONVMTX2(H,[M N]) は、行列 H に対して
% コンボリューション行列を出力します。X が M 行 N 列の行列の場合、resh-
% ape(T*X(:),size(H)+[M N]-1) は、conv2(X,H) と等価です。
% 
% クラスサポート
% -------------
% 入力はすべて、クラス double です。出力行列Tは、クラス sparse です。T 
% の中の非ゼロ要素の数は、prod(size(H))*M*N よりも多くなりません。
%
% 参考：CONVMTX, CONV2.



%   Copyright 1993-2002 The MathWorks, Inc.  
