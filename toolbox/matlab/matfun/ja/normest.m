% NORMEST   行列の2-ノルムの算出
% 
% NORMEST(S) は、行列 S の2-ノルムを計算します。
% NORMEST(S,tol) は、1.e-6の代わりに相対誤差 tol を使います。
% [nrm,cnt] = NORMEST(..) は、利用された繰り返し数も出力します。
%
% この関数は、主にスパース関数に関するものですが、大きなフル行列にも正し
% く機能し、有効である場合があります。NORM では計算時間が長くかかる大きな
% 問題や、近似ノルムでも構わないときは、NORMEST を使ってください。
%
% 参考：NORM, COND, RCOND, CONDEST.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:59 $
