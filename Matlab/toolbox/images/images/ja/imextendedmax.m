% IMEXTENDEDMAX 　拡張-maxima 変換
% BW = IMEXTENDEDMAX(I,H) は、拡張-maxima 変換を行います。これは、H-
% maxima 変換の地域的な最大値の集まりです。H は、非負のスカラです。
%
% 地域的な最大値の集まりは、周りのピクセル値が t より小さい値の強度値 t 
% をもつピクセルの連結要素群です。
%
% デフォルトで、IMEXTENDEDMAX の使用する連結度は、2次元の場合8、3次元の
% 場合26で、高次元の場合、CONNDEF(NDIMS(I),'maximal') です。 
%
% BW = IMEXTENDEDMAX(I,H,CONN) は、CONN が連結を設定する部分で、拡張-
% maxima 変換を計算します。CONN は、つぎのスカラ値のいずれかを使います。
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
% I は、任意の非スパース数値クラスで、任意の次元をもちます。BW は、I 
% と同じ大きさで、常に logical です。
%
% 例題
% -------
%       I = imread('bonemarr.tif');
%       BW = imextendedmax(I,40);
%       imshow(I), figure, imshow(BW)
%   
% 参考： CONNDEF, IMEXTENDEDMIN, IMRECONSTRUCT.



%   Copyright 1993-2002 The MathWorks, Inc.
