% ISEQUALWITHEQUALNANS   配列の数値要素の検出
%
% 数値的なデータタイプと構造体フィールドの並びは一致している必要はあり
% ません。NaN は、互いに等しいと考えられます。
%
% ISEQUALWITHEQUALNANS(A,B) は、2つの配列が同じサイズで、同じ値を
% 含む場合に1、それ以外は0です。
%
% ISEQUALWITHEQUALNANS(A,B,C,...) は、すべての入力引数が数値的に
% 等しい場合に1となります。
%
% ISEQUALWITHEQUALNANS は、セル配列と構造体の内容を再帰的に比較します。
% セル配列、または構造体のすべての要素が等しい場合、ISEQUALWITHEQUALNANS
% は、1を返します。
%
% 参考 : ISEQUAL, EQ.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:51:21 $
%   Built-in function.

