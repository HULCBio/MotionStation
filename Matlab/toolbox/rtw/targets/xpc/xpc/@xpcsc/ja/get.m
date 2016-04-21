% GET は、xpcsc オブジェクトに対するプロパティを取得します。
% 
% GET(XPCSCOPEOBJ, PROPERTYNAME) は、XPCSCOPEOBJ で表されるスコープオブジ
% ェクトからプロパティPROPERTYNAME の値を取得します。XPCSCOPEOBJ は、スコ
% ープオブジェクトのベクトルですが、行列の場合もあります。出力される行列の
% 各要素は、XPCSCOPEOBJ の対応する要素のプロパティ PROPERT YNAME に関する
% プロパティです。
% 
% PROPERTYNAME は、プロパティ名の1次元セル配列です。出力される値は、XPCS-
% COPEOBJ 行列と同じ次元のセル配列ですが、プロパティ値をストアするために
% 一つエクストラの次元をもっています。
%  
% M 行 1 列(列ベクトル)の XPCSCOPEOBJ と 1行 N 列の PROPERTYNAME に対して、
% 結果は、M 行 N 列のセル配列になります。しかし、1 行 M 列(行ベクトル) 
% XPCSCOPEOBJ に対して、結果は、1 x M x N のセル配列になります 。別の言い
% 方では、PROPERTYNAME に対応するプロパティは、最後の次元にストアされます。
% この次元のサイズが1の場合、次元は、プロパティにより置き換えられるか、ま
% たは、1でなければ、エクストラ次元が加えられます 。
% 
% 参考： SET, SET/GET 組み込み関数

%   Copyright 1994-2002 The MathWorks, Inc.
