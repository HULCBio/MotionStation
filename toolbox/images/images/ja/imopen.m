% IMOPEN イメージのオープン処理
% IM2 = IMOPEN(IM,SE) は、構造化要素 SE を使って、グレースケールイメージ
% または、バイナリイメージ上に形態学的オープン処理を適用します。SE は、単
% 一の構造化要素オブジェクトで、オブジェクトの配列ではありません。
%
% IM2 = IMOPEN(IM,NHOOD) は、構造化要素 STREL(NHOOD) を使って、オープン処
% 理を行います。ここで、NHOOD は、構造化要素近傍を指定する0と1の要素から
% なる配列です。
%
% クラスサポート
% -------------
% IM は、数値または logical で、任意のクラスと任意の次元をもちます。
% また、非スパースでなければなりません。IM が logical の場合、SE は
% 平坦でなければなりません。IM2 は、IM と同じクラスになります。
%
% 例題
% -------
% nodules1.tif イメージにスレッシュホールドを適用し、補数を計算します。
% そして、半径5の円盤を使ったオープン処理により、より小さなオブジェクト
% を抜き出します。
%
%       I = imread('nodules1.tif');
%       bw = ~im2bw(I,graythresh(I));
%       se = strel('disk',5);
%       bw2 = imopen(bw,se);
%       imshow(bw), title('Thresholded image')
%       figure, imshow(bw2), title('After opening')
%
% 参考： IMCLOSE, IMDILATE, IMERODE, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
