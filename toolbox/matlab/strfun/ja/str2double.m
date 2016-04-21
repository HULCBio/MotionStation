% STR2DOUBLE   文字列を倍精度値に変換
% 
% X = STR2DOUBLE(S) は、実数または複素スカラ値のASCIIキャラクタ表現である
% 文字列 S を、MATLABの倍精度表現に変換します。文字列は、数字、カンマ
% (1000毎のセパレータ)、小数点、+ または - 符号、10のベキ乗スケールファクタ
% 'e'、複素単位 'i' を含みます。
%
% 文字列 S が有効なスカラ値を表わさない場合、STR2DOUBLE(S) はNaNを出力
% します。
%
% X = STR2DOUBLE(C) は、文字列 C のセル配列の文字列を倍精度に変換します。
% 行列 X は、C と同じサイズで出力されます。有効なスカラ値を表わす文字列でな
% い場合は、NaN が出力されます。セル配列であるC内の個々のセルに対しては、
% NaN が出力されます。
%
% 例題
%      str2double('123.45e7')
%      str2double('123 + 45i')
%      str2double('3.14159')
%      str2double('2.7i - 3.14')
%      str2double({'2.71' '3.1415'})
%      str2double('1,200.34')
%
% 参考：STR2NUM, NUM2STR, HEX2NUM, CHAR.


%   Copyright 1984-2002 The MathWorks, Inc. 
