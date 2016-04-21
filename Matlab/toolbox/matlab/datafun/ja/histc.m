% HISTC   ヒストグラムの度数のカウント
% 
% N = HISTC(X,EDGES)は、ベクトルXに対して、ベクトルEDGES(重複を含む増加
% 関数値)内の要素間にあてはまるX内の値の個数をカウントします。Nは、これ
% らのカウント値を含むLENGTH(EDGES)のベクトルです。 
%
% N(k)は、EDGES(k) < =  X(i) < EDGES(k+1)の場合、値 X(i)をカウントします。
% 最後のビンは、EDGES(end)と一致するXの任意の値をカウントします。EDGES内
% の値以外の値は、カウントされません。すべての非NaNの値を含めるためには、
% EDGESの設定に、-inf、および、infを使ってください。
%
% 行列に対して、HISTC(X,EDGES)は、列ヒストグラムのカウントの行列です。N
% 次元配列に対して、HISTC(X,EDGES)は、最初に1でない次元に対して操作を行
% います。
%
% HISTC(X,EDGES,DIM)は、次元DIMに対して操作を行います。
%
% [N,BIN] = HISTC(X,...)は、インデックス行列BINも出力します。Xがベクトル
% の場合、N(K) = SUM(BIN =  = K)です。BINは、範囲外の値に対してはゼロで
% す。Xがm行n列行列の場合、つぎのようになります。
% 
%   for j = 1:n、N(K,j) = SUM(BIN(:,j) =  = K); end
%
% ヒストグラムをプロットするためには、BAR(X,N,'histc')を使ってください。
% 
% 例題:
%    histc(pascal(3),1:6)は、つぎの配列を出力します。 
%       [3 1 1;
%        0 1 0;
%        0 1 1;
%        0 0 0;
%        0 0 0;
%        0 0 1]
%
% 参考：HIST.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $
%   Implemented in a MATLAB mex file.
