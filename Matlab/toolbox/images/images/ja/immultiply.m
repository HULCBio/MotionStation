% IMMULTIPLY 　2つのイメージの乗算、または、イメージと定数の乗算
%
% Z = IMMULTIPLY(X,Y) は、配列 X の中の各要素を、配列 Y の中の対応する要
% 素と乗算し、結果を Z の対応する要素に出力します。
%
% X と Y が、同じサイズで同じクラスの実数の数値配列である場合、Z は、
% X と同じサイズで同じクラスになります。X が数値配列で Y がスカラの 
% double の要素の場合、Z は、X と同じサイズで、クラスになります。
%
% X が logical で、Y が数値の場合、Z は Y と同じサイズで同じクラスになり
% ます。X が数値で、Y が logical の場合、Z は X と同じサイズで同じクラス
% になります。
%
% IMMULTIPLY は、倍精度の浮動小数点で、Z の各要素を計算します。X が整数配
% 列の場合、整数タイプの範囲を超える出力要素は、打ち切られ、小数点以下は
% 丸められます。
%
% X と Y が、double の配列の場合、この関数を使用する代わりに、X.*Y を使い
% ます。
%
% 例題
% -------
% 2つの uint8 イメージを乗算し、結果を uint16 のイメージにストアします。
%
%       I = imread('moon.tif');
%       I16 = uint16(I);
%       J = immultiply(I16,I16);
%       imshow(I), figure, imshow(J)
%
% 定数ファクタで、イメージをスケーリングします。
%
%       I = imread('moon.tif');
%       J = immultiply(I,0.5);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(J)
%
% 参考： IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.  



%   Copyright 1993-2002 The MathWorks, Inc.
