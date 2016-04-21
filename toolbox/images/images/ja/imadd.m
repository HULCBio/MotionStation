% IMADD 二つのイメージの加算、または、イメージに定数を加算
%
% Z = IMADD(X,Y) は、配列 X の中の各要素に配列 Y の中の対応する要素を加
% え、出力配列 Z の中の対応する要素に出力します。X と Y は、同じサイズ、
% クラスの実数、非スパース、数値配列です。また、Y はスカラの double で
% も構いません。Z は、X と同じサイズ、クラスになります。
%
% Z = IMADD(X,Y,OUTPUT_CLASS) は、Z の希望の出力クラスを指定します。
% OUTPUT_CLASS は、以下の文字列のひとつでなければなりません。:
% 'uint8', 'uint16', 'uint32', 'int8', 'int16', and 'int32', 'single, 
% 'double'.
%
% Z が整数配列の場合、整数タイプの範囲を超える出力要素は打ち切られ、
% 小数点以下は丸められます。
%
% X と Y が double 配列の場合、この関数の代わりに、X+Y を使うこともでき
% ます。
%
% 例題 1
% -------
% 2つのイメージを加算します。
%
%       I = imread('rice.tif');
%       J = imread('cameraman.tif');
%       K = imadd(I,J);
%       imshow(K)
%
% 例題 2
% -------
% 2つのイメージを加算し、出力クラスを指定します。
%
%       I = imread('rice.tif');
%       J = imread('cameraman.tif');
%       K = imadd(I,J,'uint16');
%       imshow(K,[])
%
% 例題 3
% -------
% イメージに定数を加えます。
%
%       I = imread('rice.tif');
%       J = imadd(I,50);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(J)
%
% 参考：IMABSDIFF, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB
% 　　　IMMULTIPLY, IMSUBTRACT.



%   Copyright 1993-2002 The MathWorks, Inc.
