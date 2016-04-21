% REM   除算後の剰余
% 
% REM(x,y)は、y が0でなければ、n = fix(x./y) (ここで、n = fix(x./y))です。
% y が整数ではなく、商 x./y が整数の丸め誤差以内であれば、n は整数です。
% 定義より、REM(x,0) は、NaN になります。入力 x と y は、同じサイズの実数
% 配列または実数のスカラでなければなりません。
%
% REM(x,y) は x と同じ符号で、MOD(x,y) は y と同じ符号です。REM(x,y) と
% MOD(x,y) は、x と y が同じ符号の場合等しく、x と y の符号が異なる場合は、
% y だけ異なります。
%
% 参考：MOD.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:50:40 $
%   Built-in function.

