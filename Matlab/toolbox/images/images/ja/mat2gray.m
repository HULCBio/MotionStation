% MAT2GRAY   行列を強度イメージへ変換
%   I = MAT2GRAY(A,[AMIN AMAX]) は、行列 A を強度イメージIに変換しま
%   す。結果求まる行列Iは、0.0(黒)から1.0(フル強度、または、白)の範囲
%   の値を含んでいます。AMIN と AMAX は、I の0.0と1.0に対応する A の
%   中の値です。
%
%   I = MAT2GRAY(A) は、A の中の最小値、最大値を AMIN と AMAX の値に設
%   定します。
%
%   クラスサポート
% -------------
%   入力配列 A と出力イメージ I は、クラス double です。
%
%   例題
%   ----
%       I = imread('rice.tif');
%       J = filter2(fspecial('sobel'), I);
%       K = mat2gray(J);
%       imshow(I), figure, imshow(K)
%
%   参考：GRAY2IND



%   Copyright 1993-2002 The MathWorks, Inc.  
