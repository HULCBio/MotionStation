% FILTER   1次元ディジタルフィルタ
%
% Y = FILTER(B,A,X) は、ベクトルAとBで表わされるフィルタを使って、
% ベクトルX内のデータをフィルタリングし、フィルタ出力Yを生成します。
% フィルタは、標準の差分方程式の"Direct Form II Transposed"構造として
% 実現されます。
%
%   a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                         - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
% a(1) が1でなければ、FILTER はa(1) を使ってフィルタ係数を正規化します。
%
% FILTER は、最初の0でない次元に適用されます。言い換えれば、次元1は
% 列ベクトルと意味のある行列に対応し、次元2は行ベクトルに対応します。
%
% [Y,Zf] = FILTER(B,A,X,Zi) は、Ziでフィルタ遅延の初期条件を指定して、
% 遅れZfを出力します。Zi は、MAX(LENGTH(A),LENGTH(B))-1 の長さの
% ベクトル、または、行の長さが MAX(LENGTH(A),LENGTH(B))-1  の次元で、
% 残りの次元が X と一致する配列です。
%
% FILTER(B,A,X,[],DIM) または FILTER(B,A,X,Zi,DIM) は、次元 DIM に
% 対して機能します。
%
%   参考 ： FILTER2 , FILTFILT(Signal Processing Toolbox)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:45 $

%   Built-in function.
