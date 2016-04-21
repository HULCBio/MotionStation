% SPAUGMENT   最小二乗拡大システムの形成
% 
% S = SPAUGMENT(A,c) は、スパースな正方対称不定行列 S = [c*I A; A' 0] 
% を作成します。この行列は、
% 
%         r = b - A*x
%         S * [r/c; x] = [b; 0].
% 
% によって最小二乗問題
% 
%         min norm(b - A*x)
% 
% に関連付けられます。残差スケーリングファクタ c の最適値は、計算効率が
% 悪い min(svd(A)) と norm(r) に関連します。S = SPAUGMENT(A) は、c を指定
% しなければ、max(max(abs(A)))/1000 を使います。
%
% MATLABの以前のバージョンでは、拡大行列は正方でない問題に対して、スパース
% な線形方程式のソルバ \ や / で使われていますが、現在のMATLABでは、
% 代わりに A のqr分解を使って、最小二乗解を求めます。
%
% 参考：SPPARMS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:56 $
