% LABEL2RGB は、ラベル行列を RGB イメージに変換します。
% RGB = LABEL2RGB(L) は、関数 BWLABEL や WATERSHED により出力されるラベ
% ル行列 Lを、ラベル化された領域を可視化する目的で、カラー RGB イメージ
% に変換します。
%
% RGB = LABEL2RGB(L, MAP) は、RGB イメージで使用するカラーマップを定義し
% ます。MAP は、n 行 3 列のカラーマップ行列、カラーマップ関数の名前(たと
% えば、'jet'や'gray')を含んだ文字列、カラーマップ関数のfunction handle
% (たとえば、@jet、または、@gray) のいずれかで定義できます。LABEL2RGB は、
% L の中の各領域に対して、異なるカラーになるように MAP を計算します。
%
% RGB = LABEL2RGB(L, MAP, ZEROCOLOR) は、入力ラベル行列 L の中で、0とラ
% ベル化された要素の RGB カラーを定義します。ZEROCOLOR は、RGB の3要素、
% または、'y' (黄), 'm', (マゼンダ), 'c'(シアン), 'r'(赤), 'g' (緑), 'b' 
% (青), 'w' (白), 'k'(黒) のいずれかを設定できます。ZEROCOLOR を設定しな
% い場合、デフォルトで、[1 1 1] が使われます。
%   
% RGB = LABEL2RGB(L, MAP, ZEROCOLOR, ORDER) は、ラベル行列の中に領域に、
% カラーマップを割り当てる手法をコントロールします。ORDER が、'noshuffle'
% (デフォルト)の場合、カラーマップカラーを、数値順にラベル行列の領域に割
% り当てます。ORDER が、'shuffle' の場合、カラーマップは、擬似ランダムに
% シャッフルされます。
%   
% クラスサポート
% -------------
%
% 入力ラベル行列 L は、任意の非スパース数値クラスです。それは、有限の非
% 負の整数から構成されている必要があります。LABEL2RGB の出力は、クラス 
% uint8 です。
%
% 参考： BWLABEL, BWLABELN, ISMEMBER, WATERSHED.
%
% 例題
% -------
%   I = imread('rice.tif');
%   figure, imshow(I), title('original image')
%   BW = im2bw(I, graythresh(I));
%   L = bwlabel(BW);
%   RGB = label2rgb(L);
%   RGB2 = label2rgb(L, 'spring', 'c', 'shuffle');
%   imshow(RGB), figure, imshow(RGB2)



%   Copyright 1993-2002 The MathWorks, Inc.  
