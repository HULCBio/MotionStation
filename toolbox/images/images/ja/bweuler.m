% BWEULER   バイナリイメージの Euler 数の計算
% EUL = BWEULER(BW,N) は、バイナリイメージ BW に対して、Euler 数を出力し
% ます。EUL は、スカラ値で、イメージ内のオブジェクト総数からそれらのオブ
% ジェクトにある穴の総数を引いたものです。N には、4、または、8を設定する
% ことができ、4は4連結オブジェクト、8は8連結オブジェクトを意味します。引
% 数が設定されていない場合、デフォルト値は8です。
% 
% クラスサポート
% -------------
% BW は数値か logical で、実数の非スパースで、2次元配列でなければなりま
% せん。
% EUL は、クラス double です。
% 
% 例題
%   -------
%       BW = imread('circles.tif');
%       imshow(BW)
%       bweuler(BW)
%
% 参考：BWPERIM, BWMORPH.



%   Copyright 1993-2002 The MathWorks, Inc.  
