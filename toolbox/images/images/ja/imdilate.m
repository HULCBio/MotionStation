% IMDILATE  イメージの膨張
% IM2 = IMDILATE(IM,SE) は、グレースケール、バイナリ、パックされたバイナ
% リイメージ IM を膨張処理し、結果のイメージを IM2 に出力します。SE は、
% 関数 STREL により出力される構造化要素オブジェクト、または、構造化要素
% オブジェクトの配列です。
%
% IM が logical(バイナリ)の場合、構造化要素は平坦でなければなりません。
% また、IMDILATE は、バイナリ膨張処理を行います。その他の場合は、
% グレースケールの膨張を行います。SE が構造化要素オブジェクトの配列の
% 場合、IMDILATE は、SE の中の個々の構造化要素を連続的に使って、複数の
% 膨張処理を行います。
%
% IM2 = IMDILATE(IM,NHOOD) は、イメージ IM に膨張処理を適用します。ここ
% で、NHOOD は、構造化要素近傍を指定する0と1の要素から構成される行列です。
% これは、シンタックス IMDILATE(IM, STREL(NHOOD)) と等価です。IMDILATE 
% は、FLOOR((SIZE(NHOOD) + 1)/2) を使って、近傍の中心要素を決定します。
%
% IM2 = IMDILATE(IM,SE,PACKOPT)、または、IMDILATE(IM,NHOOD,PACKOPT) は、
% IM がパックされたバイナリイメージか否かを指定します。PACKOPT は、つぎ
% の値のいずれかを設定します。
%
%       'ispacked'    IM は、BWPACK で出力されるパックされたバイナリイメ
%                     ージとして取り扱われます。IM は、2次元の uint32 配
%                     列で、SE は、平坦な2次元構造化要素です。PACKOPT の
%                     値が、'ispacked' の場合、PADOPT は、'same' に設定す
%                     る必要があります。
%
%       'notpacked'   IM は、通常の配列と同様に取り扱われます。これが、デ
%                     フォルト値です。
%
% IM2 = IMDILATE(...,PADOPT) は、出力イメージのサイズを指定します。PADOPT
% は、つぎの値のいずれかを設定します。
%
%       'same'        出力イメージを、入力イメージのサイズと同じにしま
%                     す。これが、デフォルト値です。PACKOPT が、'ispa-
%                     cked'の場合、PADOPT は、'same' に設定する必要があ
%                     ります。
%
%       'full'        フルの膨張処理を計算します。
%
% PADOPT は、関数 CONV2 や FILTER2 へのオプションの SHAPE 引数に似ています。
%
% クラスサポート
% -------------
% IM は、logical か数値で、実数の非スパースでなければなりません。これは
% 任意の次元をもちます。出力は、入力と同じクラスになります。入力がパック
% されたバイナリの場合、出力もパックされたバイナリになります。
%
% 例題
% --------
% バイナリイメージ text.tif を垂直線を使って、膨張処理します。
%
%       bw = imread('text.tif');
%       se = strel('line',11,90);
%       bw2 = imdilate(bw,se);
%       imshow(bw), title('Original')
%       figure, imshow(bw2), title('Dilated')
%
% グレースケールイメージ cameraman.tif を、ローリングボールを使って、膨張
% 処理します。
%
%       I = imread('cameraman.tif');
%       se = strel('ball',5,5);
%       I2 = imdilate(I,se);
%       imshow(I), title('Original')
%       figure, imshow(I2), title('Dilated')
%
% スカラ値1を、2つの構造化要素を連続的に適用し、'full'オプションを使って、
% 膨張処理を行うことにより、2つの平坦な構造化要素を組み合わせたものを作成
% します。
%
%       se1 = strel('line',3,0);
%       se2 = strel('line',3,90);
%       composition = imdilate(1,[se1 se2],'full')
%
% 参考：BWPACK, BWUNPACK, CONV2, FILTER2, IMCLOSE, IMERODE, IMOPEN,
%       STREL.



%   Copyright 1993-2002 The MathWorks, Inc. 
