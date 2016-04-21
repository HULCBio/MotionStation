% IMCOMPLEMENT 　イメージの補数
% IM2 = IMCOMPLEMENT(IM) は、イメージ IM の補数を計算します。IM は、バイ
% ナリ、強度、RGB イメージのいずれかです。IM2 は、IM と同じクラスで、同じ
% サイズです。
%
% バイナリイメージの補数は、0が1に、1が0になります。すなわち、黒と白が反
% 転します。強度イメージや RGB イメージの補数は、各ピクセル値をクラスでサ
% ポートしている最大数から引き算します。倍精度イメージでは、1.0 から引き
% ます。そして、その結果である差が、出力イメージ内のピクセル値として使わ
% れます。出力イメージの中で、暗い領域は、より明るく、明るい領域はより暗
% くなります。
%
% 注意
% ----
% IM が double の強度イメージ、または、RGB イメージの場合、この関数を使う
% 代わりに、1-IM を使うことができます。IM がバイナリイメージの場合、この
% 関数を使う代わりに、~IM を使うことができます。
%
% 例題
% -------
%       I = imread('bonemarr.tif');
%       J = imcomplement(I);
%       imshow(I), figure, imshow(J)
%
% 参考：IMABSDIFF, IMADD, IMDIVIDE, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 



%   Copyright 1993-2002 The MathWorks, Inc.
