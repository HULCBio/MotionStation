% IMDIVIDE 　2つのイメージの除算、または、イメージを定数で除算
% Z = IMDIVIDE(X,Y) は、配列 X の中の各要素を、配列 Y の中の対応する要素
% で除算し、結果を Z の対応する要素に出力します。X と Y が、共に、実数、
% 非スパース、数値配列であるか、または、Y がスカラの double の要素の場合、
% Z は、X と同じサイズで、クラスになります。
%
% X が整数配列の場合、整数タイプの範囲を超える出力要素は、打ち切られ、
% 小数点以下は丸められます。
%
% X と Y が、double の配列の場合、この関数を使用する代わりに、X./Y を
% 使います。
%
% 例題
% -------
% rice イメージのバックグランドを計算し、それとの除算を行います。
%
%       I = imread('rice.tif');
%       blocks = blkproc(I,[32 32],'min(x(:))');
%       background = imresize(blocks,[256 256],'bilinear');
%       Ip = imdivide(I,background);
%       imshow(Ip,[])
%
%  イメージを定数で除算します。
%
%       I = imread('rice.tif');
%       J = imdivide(I,2);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(J)
%
% 参考： IMADD, IMCOMPLEMENT, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 



%   Copyright 1993-2002 The MathWorks, Inc.
