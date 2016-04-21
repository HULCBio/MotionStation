% STRETCHLIM 　Find limits to contrast stretch an image.
% LOW_HIGH = STRETCHLIM(I,TOL) は、イメージのコントラストを増加するた
% めに、IMADJUST で使用できる強度の組を出力します。
%
% TOL = [LOW_FRACT HIGH_FRACT] は、低い強度と高い強度で飽和するように、
% イメージの分割を指定します。
%
% TOL がスカラの場合、TOL = LOW_FRACT と HIGH_FRACT = 1 - LOW_FRACT で、
% 低い強度値と高い強度値で同じ分割になるようにします。
%
% 引数を省略すると、TOL は、デフォルトで、[0.01 0.99]、2% の飽和を示し
% ます。
%
% TOL = 0 の場合、LOW_HIGH = [min(I(:)) max(I(:))] です。
%
% LOW_HIGH = STRETCHLIM(RGB,TOL) は、RGB イメージの各平面の彩度を 2 行 
% 3 列の強度イメージに出力します。TOL は、各平面の彩度に対して、同じ分
% 割を指定します。
%
% クラスサポート
% -------------
% 入力イメージは、クラス uint8, uint16, double のいずれでも構いません。
% 出力強度は、クラス double で、0 と 1 の間の数です。
%
% 例題
% -------
%       I = imread('pout.tif');
%       J = imadjust(I,stretchlim(I),[]);
%       imshow(I), figure, imshow(J)
%
% 参考： BRIGHTEN, HISTEQ, IMADJUST.



%   Copyright 1993-2002 The MathWorks, Inc.  
