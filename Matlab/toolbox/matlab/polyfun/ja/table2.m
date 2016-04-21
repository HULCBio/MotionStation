% TABLE2   2次元のtable look-up
% 
% Z = TABLE2(TAB,X0,Y0) は、TAB の1列目の X0 と1行目の Y0 を調べ、2次元
% のテーブル TAB から線形補間された共通部分を出力します。TAB は、1行目と
% 1列目にキーの値を含み、残りのブロックにデータを含む行列です。1行目と
% 1列目は、単調関数でなければなりません。TAB(1,1) のキーは無視されます。
%
% 例題:
%    tab = [NaN 1:4; (1:4)' magic(4)];
%    y = table2(tab,1:4,1:4)
% は、y = magic(4) を出力するためには、効率の悪い方法です。
%
% 関数 TABLE2 は廃止された関数なので、INTERP2 を使ってください。
%
% 参考：INTERP2, TABLE1.


%   Paul Travers 7-14-87
%   Revised JNL 3-15-89
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:58 $
