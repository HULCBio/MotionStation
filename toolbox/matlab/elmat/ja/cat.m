% CAT   配列の連結
% 
% CAT(DIM,A,B)は、次元DIMについて配列AとBを連結します。
% CAT(2,A,B)は、[A,B]と同じです。
% CAT(1,A,B)は、[A;B]と同じです。
%
% B = CAT(DIM,A1,A2,A3,A4,...)は、次元DIMについて、入力配列A1、A2等を連
% 結します。
%
% カンマで区切られたリストのシンタックスを用いると、CAT(DIM,C{:})、また
% は、CAT(DIM,C.FIELD)は、数値行列を含むセル配列や構造体配列を単一の行列
% に連結する便利な方法です。
%
% 例題:
%   a = magic(3); b = pascal(3); 
%   c = cat(4,a,b)
% 
% は、3*3*1*2の配列を作ります。
% 
%   s = {a b};
%   for i = 1:length(s)、
%     siz{i} = size(s{i});
%   end
%   sizes = cat(1,siz{:})
% 
% は、サイズベクトルからなる2行2列の配列を作ります。
% 
% 参考：NUM2CELL.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:50:58 $
%   Built-in function.

