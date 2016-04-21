% IMABSDIFF 2つのイメージの差の絶対値を計算
% Z = IMABSDIFF(X,Y) は、配列 X の中の各要素から、対応する配列 Y の要素
% を引き、その絶対値を出力配列 Z に出力します。X と Y は、同じクラスと
% サイズをもつ実数、非スパース、数値配列です。Z は、X と Y と同じクラス、
% サイズをもっています。X と Y が整数配列の場合、整数タイプの範囲を超え
% た出力内の要素は、打ち切られます。
%
% X と Y が double 配列の場合、この関数の代わりに、ABS(X-Y) を使うことが
% できます。
%
% 例題
% -------
% フィルタリングしたイメージとオリジナルイメージの間の差の絶対値を表示し
% ます。
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imabsdiff(I,J);
%       imshow(K,[])
%
% 参考：IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.  



%   Copyright 1993-2002 The MathWorks, Inc.
