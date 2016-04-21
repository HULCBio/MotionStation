% ISFINITE   配列の有限要素の検出
% 
% ISFINITE(X)は、Xの要素が有限であれば1を、そうでなければ0を要素としても
% つ配列を出力します。たとえば、ISFINITE([pi NaN Inf -Inf])は、[1 0 0 0]
% を出力します。
%
% 任意のXに対して、3つの量ISFINITE(X)、ISINF(X)、ISNAN(X)の中の1つは、各
% 要素が1になります。
%
% 参考：ISNAN, ISINF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:22 $
%   Built-in function.
