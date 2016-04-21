% GRAYTHRESH  Otsu 法を使って、グローバルイメージスレッシュホールドを計算
% LEVEL = GRAYTHRESH(I) は、強度イメージをバイナリイメージに IM2BW を使
% って、変換するときに使用するグローバルスレッシュホールドを計算します。
% LEVEL は、[0, 1]の範囲に入る正規化された強度値です。GRAYTHRESH は、
% Otsu の方法を使います。この方法は、スレッシュホールドを適用する黒ピク
% セルと白ピクセルの内部クラスでの分散を最小にするようにスレッシュホール
% ドを選択します。
%
% クラスサポート
% -------------
% 入力イメージ I は、クラス uint8, uint16, double のいずれかで設定でき、
% 非スパースである必要があります。出力 LEVEL は、double のスカラです。
%
% 例題
% -------
%       I = imread('blood1.tif');
%       level = graythresh(I);
%       BW = im2bw(I,level);
%       imshow(BW)
%
% 参考： IM2BW



%   Copyright 1993-2002 The MathWorks, Inc.  
