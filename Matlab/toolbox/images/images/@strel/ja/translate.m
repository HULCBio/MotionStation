% TRANSLATE 構造化要素の変換
% SE2 = TRANSLATE(SE,V) は、N-次元空間の構造化要素 SE を変換します。V 
% は、各次元の中で、希望する変換のオフセットを含む N 要素のベクトルです。
%
% 例題
%   -------
% STREL(1) の変換されたバージョンを使った膨張は、空間内で、入力イメージを
% 変換する一つの方法です。この例題は、cameraman.tif イメージを、25 ピクセ
% ルの正方形に変換するものです。
%
%       I = imread('cameraman.tif');
%       se = translate(strel(1), [25 25]);
%       J = imdilate(I,se);
%       imshow(I), title('Original')
%       figure, imshow(J), title('Translated');
%
% 参考：STREL, STREL/REFLECT.



% $Revision: 1.1 $
%   Copyright 1993-2002 The MathWorks, Inc.
