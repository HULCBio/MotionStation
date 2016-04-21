% INT2STR   整数を文字列に変換
% 
% S = INT2STR(X) は、行列 X の要素を整数に丸めて、その結果を文字列
% 行列に変換します。
% NaN と Inf の要素は、それぞれ文字列 'NaN' と 'Inf' として再帰的に
% 返されます。
%
% 参考：NUM2STR, SPRINTF, FPRINTF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:49 $

