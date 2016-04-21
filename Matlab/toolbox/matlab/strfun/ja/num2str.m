% NUM2STR   数値を文字列に変換
% 
% T = NUM2STR(X) は、行列 X を4桁の精度で、必要ならば指数表示で文字列
% 表現 T に変換します。これは、TITLE、XLABEL、YLABEL、TEXT コマンドを
% 使って、プロットにラベルを付けるのに役立ちます。
%
% T = NUM2STR(X,N) は、行列 X を、最大で N 桁の精度で、文字列表現に変換
% します。デフォルトの桁数は、X の要素の大きさに基づきます。
%
% T = NUM2STR(X,FORMAT) は、書式文字列 FORMAT を使います(詳細は、
% SPRINTF を参照)。 
%
% 例題:
% 
% num2str(randn(2,2),3) は、つぎの文字列行列を出力します。
%
%       '-0.433    0.125'
%       ' -1.67    0.288'
%
% 参考：INT2STR, SPRINTF, FPRINTF.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:06:57 $
