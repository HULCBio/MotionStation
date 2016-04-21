% IMSUBTRACT  2つのイメージの減算、または、イメージから定数を減算
% Z = IMSUBTRACT(X,Y) は、配列 X の中の各要素に配列 Y の中の対応する要
% 素を引き、出力配列 Z の中の対応する要素に出力します。X と Y は、同じ
% サイズ、クラスの実数、非スパース、数値配列です。また、Y はスカラの 
% double でも構いません。Z は、X と同じサイズ、クラスになります。
%
% X が整数配列の場合、整数タイプの範囲を超える出力要素は、打ち切られ、
% 小数点以下は丸められます。
%
% X と Y が double 配列の場合、この関数の代わりに、X-Y を使うこともでき
% ます。
%
% 例題
% -------
% rice イメージのバックグランドを計算し、引き算します。
%       I = imread('rice.tif');
%       blocks = blkproc(I,[32 32],'min(x(:))');
%       background = imresize(blocks,[256 256],'bilinear');
%       Ip = imsubtract(I,background);
%       imshow(Ip,[])
%
% rice イメージから定数値を引きます。
%       I = imread('rice.tif');
%       Iq = imsubtract(I,50);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(Iq)
%
% 参考： IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMMULTIPLY.



%   Copyright 1993-2002 The MathWorks, Inc. 
