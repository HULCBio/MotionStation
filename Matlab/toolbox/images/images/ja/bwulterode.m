% BWULTERODE  最終的な縮退
% BW2 = BWULTERODE(BW) は、バイナリイメージ BW の最終的な縮退を計算しま
% す。BW の最終的な縮退とは、BW の補数のユークリッド距離変換の地域的な最
% 大値の集まりから構成されています。地域的な最大値の集まりに関するデフォ
% ルトの連結度は2次元の場合8、3次元の場合26で、高次元の場合、CONNDEF(ND-
% IMS(BW),'maximal') です。
%
% BW2 = BWULTERODE(BW,METHOD,CONN) は、距離変換手法と地域的な最大値の集
% まりの連結度を設定することができます。METHOD は、文字列 'euclidean', 
% 'cityblock', 'chessboard', 'quasi-euclidean' のいずれかを設定すること
% ができます。CONN は、つぎのスカラ値のいずれかを使用します。 
%
%       4     2次元4連結近傍
%       8     2次元8連結近傍
%       6     3次元6連結近傍
%       18    3次元18連結近傍
%       26    3次元26連結近傍
%
% 連結度は、CONN に対して、0と1を要素とする3 x 3 x 3 x ... x 3 の行列を
% 使って、任意の次元に対して、より一般的に定義できます。値1は、CONN の
% 中心要素に関連して近傍の位置を設定します。CONN は、中心要素に対して、
% 対称である必要があります。
%
% クラスサポート
% -------------
% BW は、数値か logical で、非スパースでなければなりません。任意の次元を
% 使うことができます。BW2 は、常に logical になります。
%
% 例題
% -------
%       bw = imread('circles.tif');
%       imshow(bw), title('Original')
%       bw2 = bwulterode(bw);
%       figure, imshow(bw2), title('Ultimate erosion')
%
% 参考：BWDIST, CONNDEF, IMREGIONALMAX.



%   Copyright 1993-2002 The MathWorks, Inc.
