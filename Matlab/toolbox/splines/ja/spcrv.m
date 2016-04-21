% SPCRV   一様な区分によるスプライン曲線
%
% CURVE = SPCRV(X) は、入力(d,n)の配列 X から、[K/2 .. n-K/2] の範囲の 
% t に対するスプライン
%
%      t |-->  sum  B(t-K/2;j,...,j+k)*X(j)  
%               j
%
% の連続的な値 CURVE(:,i) の適切な列を生成するために、中点の節点の挿入を
% 繰り返し行います。
% d>1 の場合、各 CURVE(:,i) は、スプライン曲線上の点です。
% 挿入の処理は、節点が MAXPNT 個以上になると終了します。
% K のデフォルトは4で、MAXPNT のデフォルトは100です。
%
% CURVE = SPCRV(X,K) は、次数 K も指定します。
%   
% CURVE = SPCRV(X,K,MAXPNT) は、出力される点の数に対して、下限 MAXPNT も
% 指定します。
%
% 例題:
%
%     k=3; c = spcrv([1 0;0 1;-1 0;0 -1; 1 0].',k); plot(c(1,:),c(2,:))
%
% は、近似した円の3/4をプロットし、k=4 のときは近似した円の半分のみを
% プロットします。
%
% 参考 : CSCVN, SPCRVDEM, SPALLDEM.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
