% BWHITMISS 　バイナリ hit-miss 演算
% 
% BW2 = BWHITMISS(BW,SE1,SE2) は、構造化要素 SE1 と SE2 で定義した hit-
% miss 演算を行います。hit-miss 演算は、SE1 の型に"一致"するピクセルの
% 近傍と、SE2 の型に一致しないものを保存します。SE1 と SE2 は STREL 関
% 数、または近傍配列によって返される平坦な構造化要素オブジェクトです。
% SE1 と SE2 の領域は共通の要素をもっていません。BWHITMISS(BW,SE1,SE2) 
% は、IMERODE(BW,SE1) & IMERODE(~BW,SE2) と等価です。
%
% BW2 = BWHITMISS(BW,INTERVAL) は、"INTERVAL"と呼ばれる単一配列の項で定義
% した hit-miss 演算を行います。INTERVAL は、1, 0, -1 のいずれかを要素と
% する配列です。値1は、SE1 の領域を作り、値 -1 は、SE2 の領域を作ります。
% そして、値 0 は、無視します。
% 
% BWHITMISS(INTERVAL) は、BWHITMISS(BW,INTERVAL == 1,INTERVAL == -1) と等
% 価です。
%
% クラスサポート
% -------------
% BW1 は、非スパースの logical か任意のクラスの数値配列です。BW2 は、
% 常に BW1 と同じサイズの logical です。SE1 と SE2 は平坦な STREL オブ
% ジェクトか、1と0のみを含む logical か数値配列でなければなりません。
% INTERVAL は、1、0、-1のいずれかを含んだ配列でなければなりません。
%
%   例題
%   -------
%       bw = [0 0 0 0 0 0
%             0 0 1 1 0 0
%             0 1 1 1 1 0
%             0 1 1 1 1 0
%             0 0 1 1 0 0
%             0 0 1 0 0 0]
%
%       interval = [0 -1 -1
%                   1  1 -1
%                   0  1  0];
%
%       bw2 = bwhitmiss(bw,interval)
%
% 参考：IMDILATE, IMERODE, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.
