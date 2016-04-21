% SQRTM   行列の平方根
% 
% X = SQRTM(A )は、A の行列の平方根を計算します。つまり X*X = A です。
%
% X は、すべての固有値が非負の実部をもつ、ユニークな正方行列です。
% A が負の実数値の固有値をもつ場合は、結果は複素数になります。
% A が特異行列の場合、A は平方根をもちません。
% 特異性が検出された場合はワーニングを表示します。
%
% 2つの出力引数を指定した場合、[X, RESNORM] = SQRTM(A) は、警告メッセージ
% は表示しませんが、残差 norm(A-X^2,'fro')/norm(A,'fro') を出力します。
%
% 3つの出力引数を指定した場合、[S、ALPHA、CONDEST] = SQRTM(A) は、安定因
% 子 ALPHA と X の行列の平方根の条件数の推定値 CONDEST を出力します。残差 
% norm(A-X^2,'fro')/norm(A,'fro') は、(n+1)*ALPHA*EPS を境界とし、X の
% Frobenius ノルムに関連したエラーは、N*ALPHA*CONDEST*EPS を境界とします。
% ここで、N = MAX(SIZE(A)) です。
%
% 参考：EXPM, LOGM, FUNM.

%   参考文献:
%   N. J. Higham, Computing real square roots of a real
%       matrix, Linear Algebra and Appl., 88/89 (1987), pp. 405-430.
%   A. Bjorck and S. Hammarling, A Schur method for the square root of a
%       matrix, Linear Algebra and Appl., 52/53 (1983), pp. 127-140.
%
%   Nicholas J. Higham
%   Copyright 1984-2002 The MathWorks, Inc.
