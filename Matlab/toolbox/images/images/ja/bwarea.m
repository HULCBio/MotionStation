% BWAREA    バイナリイメージの中でオブジェクトの面積を計算
% TOTAL = BWAREA(BW) は、バイナリイメージ BW 内のオブジェクトの面積を計
% 算します。TOTAL は、スカラ値で、イメージ内の on 状態のピクセルの総数を
% 大まかに表します。しかし、ピクセルの様々なパターンに個々の重みが加えら
% れているので、正確には同じものにならない可能性があります。
% 
% クラスサポート
% -------------
% BW は数値または logical です。入力が数値のケースでは、任意の非ゼロの
% ピクセルは"オン"と考えられます。TOTAL はクラス double です。
% 
% 例題
%   -------
%       BW = imread('circles.tif');
%       imshow(BW)
%       bwarea(BW)
%
% 参考：BWPERIM, BWEULER.



%   Copyright 1993-2002 The MathWorks, Inc.  
