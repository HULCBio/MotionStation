% IMERODE  イメージの縮退処理
%
% IM2 = IMERODE(IM,SE) は、グレースケール、バイナリ、パックされたバイナ
% リイメージ IM を縮退処理し、結果のイメージを IM2 に出力します。SE は、
% 関数 STREL により出力される構造化要素オブジェクト、または、構造化要素
% オブジェクトの配列です。
%
% IM が logical で、構造化要素が平坦な場合、IMERODE は、バイナリ縮退処理
% を行い、その他の場合は、グレースケール縮退を行います。SE が、構造化要
% 素オブジェクトの配列の場合、IMERODE は、SE の中の個々の構造化要素を連
% 続的に使って、複数の縮退処理を行います。
%
% IM2 = IMERODE(IM,NHOOD) は、イメージ IM に縮退処理を適用します。ここ
% で、NHOOD は、構造化要素近傍を指定する0と1の要素から構成される行列で
% す。これは、シンタックス IMERODE(IM,STREL(NHOOD)) と等価です。IMERODE
% は、FLOOR((SIZE(NHOOD) + 1)/2) を使って、近傍の中心要素を決定します。
%
% IM2 = IM2 = IMERODE(IM,SE,PACKOPT,M)、または、IMERODE(IM,NHOOD,.....
% PACKOPT,M) は、IM がパックされたバイナリイメージか否かを、また、オリジ
% ナルのパックされていないイメージの行次元 M を与えるか否かを指定します。
% PACKOPT は、つぎの値のいずれかを設定します。
% 
%       'ispacked'    IM は、BWPACK で出力されるパックされたバイナリイ
%                     メージとして取り扱われます。IM は、2次元のuint32 
%                     配列で、SE は、平坦な2次元構造化要素です。PACKOPT 
%                     の値が、'ispacked' の場合、PADOPT は、'same' に設
%                     定する必要があります。
%
%       'notpacked'   IM は、通常の配列と同様に取り扱われます。これが、
%                     デフォルト値です。
%
% PACKOPT が、'ispacked' の場合、M に対する値を設定する必要があります。
%
% IM2 = IMERODE(...,PADOPT) は、出力イメージのサイズを指定します。PADOPT
% は、つぎの値のいずれかを設定します。
%
%       'same'        出力イメージを、入力イメージのサイズと同じにしま
%                     す。これが、デフォルト値です。PACKOPT が、'isp-
%                     acked'の場合、PADOPT は、'same' に設定する必要が
%                     あります。
%
%       'full'        フルの縮退処理を計算します。
%
% PADOPT は、関数 CONV2 や FILTER2 へのオプションの SHAPE 引数に似ていま
% す。
%
% クラスサポート
% -------------
% IM は、数値または logical で、任意の次元です。IM が logical で、構造化
% 要素が平坦ならば、出力は、uint8 のバイナリイメージになり、その他の
% 場合、出力は、入力と同じクラスになります。入力がパックされたバイナリ
% の場合、出力もパックされたバイナリになります。 
% 
% 例題
%   --------
% バイナリイメージ text.tif を垂直線を使って、縮退処理します。
%
%
%       bw = imread('text.tif');
%       se = strel('line',11,90);
%       bw2 = imerode(bw,se);
%       imshow(bw), title('Original')
%       figure, imshow(bw2), title('Eroded')
%
% グレースケールイメージ cameraman.tif を、ローリングボールを使って、縮退
% 処理します。
%
%       I = imread('cameraman.tif');
%       se = strel('ball',5,5);
%       I2 = imerode(I,se);
%       imshow(I), title('Original')
%       figure, imshow(I2), title('Eroded')
%
% 参考：BWPACK, BWUNPACK, CONV2, FILTER2, IMCLOSE, IMDILATE, IMOPEN,
%       STREL.



%   Copyright 1993-2002 The MathWorks, Inc. 
