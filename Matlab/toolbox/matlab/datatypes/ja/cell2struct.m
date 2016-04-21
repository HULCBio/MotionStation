% CELL2STRUCT   セル配列を構造体配列に変換
% 
% S = CELL2STRUCT(C,FIELDS,DIM)は、Cの次元DIMをSのフィールドに含ませる
% ことにより、セル配列Cを構造体Sに変換します。SIZE(C,DIM)は、FIELDS内
% のフィールド名の数と一致しなければなりません。FIELDSは、文字列配列、
% または、文字列のセル配列でも構いません。
%
% 例題:
%     c = {'tree',37.4,'birch'};
%     f = {'category','height','name'};
%     s = cell2struct(c,f,2);
%
% 参考：STRUCT2CELL, FIELDNAMES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:09 $
%   Built-in function.
