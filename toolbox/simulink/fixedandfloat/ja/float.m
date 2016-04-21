% float  - 浮動小数点データタイプを記述する構造体の作成
%
%
% このデータタイプオブジェクトは、Fixed Point Blocksetに渡されます。
%
% FLOAT( 'single' )
%
%  IEEE Single?I?f?[?^?^?C?v?d?L?q?・?eMATLAB?\'￠'I?d?o-I (32?A?I'??r?b?g?
% A8?A?I?w?"?r?b?g).
%
% FLOAT( 'double' )
%
%  IEEE Doubleのデータタイプを記述するMATLAB構造体を出力 (64個の総ビット、
% 11個の指数ビット).
%
% FLOAT( TotalBits, ExpBits )
%
%  浮動小数点データタイプを記述するMATLAB構造体を出力
% データタイプは、IEEEスタイルと似ていると仮定されます。
%  たとえば、最小の指数を除く全ての指数について、表示されない1を使って数値は
% 正規化されます。しかしながら、最大の指数は、INFおよびNANのフラグとしては扱わ
% れません。
%
% 注意： 固定小数点数とは異なり、浮動小数点数は以下の指定されたスケーリングを
% 無視します： radix point, slope, bias.浮動小数点数と実際の数値は同じです。
%
% 参考 : SFIX, UFIX, SINT, UINT, UFRAC, FLOAT.


% Copyright 1994-2002 The MathWorks, Inc.
