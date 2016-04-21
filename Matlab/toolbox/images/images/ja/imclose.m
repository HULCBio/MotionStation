% IMCLOSE  イメージのクローズ処理
% IM2 = IMCLOSE(IM,SE) は、構造化要素 SE を使って、グレースケールイメージ
% または、バイナリイメージ上に形態学的クローズ処理を適用します。SE は、単
% 一の構造化要素オブジェクトで、オブジェクトの配列ではありません。
%
% IMCLOSE(IM,NHOOD) は、構造化要素 STREL(NHOOD) を使って、クローズ処理を
% 行います。ここで、NHOOD は、構造化要素近傍を指定する0と1の要素からなる
% 配列です。
%
% クラスサポート
% -------------
% IM は、任意の数値または logical のクラスで、任意の次元です。また非ス
% パースでなければなりません。IM が logical の場合、SE は平坦でなければ
% なりません。IM2 は IM と同じクラスになります。
%
% 例題
% -------
% pearlite.tif イメージにスレッシュホールドを適用し、半径6の円盤にクロー
% ズ処理を行い、クローズ処理に伴う小さな形状をマージします。孤立している
% 白色ピクセルを除去するには、その後で、オープン処理を行います。
%
%       I = imread('pearlite.tif');
%       bw = ~im2bw(I,graythresh(I));
%       imshow(I), title('Original')
%       figure, imshow(bw), title('Step 1: threshold')
%       se = strel('disk',6);
%       bw2 = imclose(bw,se);
%       bw3 = imopen(bw2,se);
%       figure, imshow(bw2), title('Step 2: closing')
%       figure, imshow(bw3), title('Step 3: opening')
%
% 参考：IMDILATE, IMERODE, IMOPEN, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
