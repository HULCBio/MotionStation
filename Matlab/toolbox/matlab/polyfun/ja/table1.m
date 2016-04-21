% TABLE1   1次元のtable look-up
% 
% Y = TABLE1(TAB,X0) は、TAB の1列目の X0 を調べ、テーブル TAB から線形
% 補間された行のテーブルを出力します。TAB は、1列目にキーの値を含み、
% 残りの列にデータを含む行列です。TAB の補間された行は、X0 の各要素に
% 対して出力されます。TAB の1列目は、単調関数でなければなりません。
%
% 例題:
%    tab = [(1:4)' magic(4)];
%    y = table1(tab,1:4);
% は、y = magic(4) を出力するためには、効率の悪い方法です。
%
% 関数 TABLE1 は廃止された関数なので、INTERP1 または INTERP1Q を使って
% ください。
%
% 参考：INTERP1, INTERP2, TABLE2.


%   Tomas Schoenthal 5-1-85
%   Egbert Kankeleit 1-15-87
%   Revised by L. Shure 2-3-87
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:57 $
