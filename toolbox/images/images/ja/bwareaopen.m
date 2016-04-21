% BWAREAOPEN バイナリ領域のオープン処理：小さいオブジェクトを削除
% BW2 = BWAREAOPEN(BW,P) は、P個のピクセルより少ないピクセルの連結部分
% をバイナリイメージから除去し、バイナリイメージ BW2 を作成します。デ
% フォルトの連結度は、2次元で8、3次元で26、高次元で、CONNDEF(NDIMS(BW),
% 'maximal')です。
%
% BW2 = BWAREAOPEN(BW,P,CONN) は、希望する連結度を指定します。CONN は、
% つぎのスカラ値を設定することができます。
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
% BW は、logical か任意の次元の数値配列で、非スパースでなければなりま
% せん。
%
% BW2 は、logical です。
%
% 例題
% -------
% イメージ text.tif の中の40ピクセル以下のオブジェクトを除去します。
%
%       bw = imread('text.tif');
%       imshow(bw), title('Original')
%       bw2 = bwareaopen(bw,40);
%       figure, imshow(bw2), title('Area open (40 pixels)')
%
% 参考：BWLABEL, BWLABELN, CONNDEF, REGIONPROPS.



%   Copyright 1993-2002 The MathWorks, Inc.
