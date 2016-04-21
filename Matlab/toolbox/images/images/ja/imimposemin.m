% IMIMPOSEMIN 　Minima の割り当て
% I2 = IMIMPOSEMIN(I,BW) は、形態学的な再構成法を使って、強度イメージ I 
% を変更します。それで、BW が非ゼロの部分のみ、地域的な最小値の集まりを
% もちます。
%
% デフォルトでは、IMIMPOSEMIN は、2次元イメージで、8連結近傍、3次元イメ
% ージで、26連結近傍を使います。高次元の場合は、CONNDEF(NDIMS(I),'maxi-
% mal') を使います。 
%
% シンタックス I2 = IMIMPOSEMIN(I,BW,CONN) は、デフォルトの連結度を書き
% 換えます。CONN は、つぎのスカラ値のいずれかを設定することができます。
%
%       4     2次元4連結近傍
%       8     2次元8連結近傍
%       6     3次元6連結近傍
%       18    3次元18連結近傍
%       26    3次元26連結近傍
%
% 連結度は、CONN に対して、0と1を要素とする3 x 3 x 3 x ... x 3 の行列を
% 使って、任意の次元に対して、より一般的に定義できます。値1は、CONN の中
% 心要素に関連して近傍の位置を設定します。CONN は、中心要素に対して、対
% 称である必要があります。
%   
% クラスサポート
% -------------
% I は、任意の非スパース数値クラスで、任意の次元を持っています。BW は、
% I と同じ大きさの非スパース配列でなければなりません。I2 は、I と同じ
% サイズで同じクラスになります。
%
% 例題
% -------
% bonemarr の中のイメージを修正します。そして、ある位置で、地域的な最小値
% の集まりを作ります。
%
%       I = imread('bonemarr.tif');
%       imshow(I), title('Original image')
%       bw = zeros(size(I));
%       bw(98:102,101:105) = 1;
%       J = I;
%       J(bw ~= 0) = 255;
%       figure, imshow(J)
%       title('Image with desired minima location superimposed')
%       K = imimposemin(I,bw);
%       figure, imshow(K)
%       title('Modified image')
%       bw2 = imregionalmin(K);
%       figure, imshow(bw2)
%       title('Regional minima of modified image')
%
% 参考： CONNDEF, IMRECONSTRUCT, IMREGIONALMIN.



%   Copyright 1993-2002 The MathWorks, Inc.
