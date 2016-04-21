% DCT2    2次元離散コサイン変換の計算
% B = DCT2(A) は、A の離散コサイン変換を出力します。行列 B は、A と同じ
% 大きさで、離散コサイン変換係数を含んでいます。
% 
% B = DCT2(A,[M N])、または、B = DCT2(A,M,N) は、変換する前に0を付加して
% M 行 N 列の大きさに行列 A を整形します。M、または、N が、A の対応する
% 大きさよりも小さい場合、DCT2 は、A の要素を切り捨てます。
% 
% IDCT2 を使うと、この逆の変換をすることができます。
% 
% クラスサポート
% -------------
% A は、数値または logical です。出力される行列 B は、クラス double 
% です。
% 
% 例題
% -------
%       RGB = imread('autumn.tif');
%       I = rgb2gray(RGB);
%       J = dct2(I);
%       imshow(log(abs(J)),[]), colormap(jet), colorbar
%
% つぎのコマンドは、DCT 行列の中で大きさが10以下のものを0に設定し、逆 
% DCT 関数 IDCT2 を使って、イメージを再構成します。
%
%       J(abs(J)<10) = 0;
%       K = idct2(J);
%       imshow(I), figure, imshow(K,[0 255])
%
% 参考：FFT2, IDCT2, IFFT2.


%   Copyright 1993-2002 The MathWorks, Inc.  
