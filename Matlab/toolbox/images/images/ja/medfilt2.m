% MEDFILT2   2次元のメディアンフィルタリング
%
% B = MEDFILT2(A,[M N]) は、行列 A に2次元のメディアンフィルタリング
% を実行します。各出力ピクセルには、入力イメージの対応するピクセル周
% 囲の M 行 N 列の近傍の中央値を設定します。MEDFILT2 は、エッジの上
% に0を付加するので、エッジの[M N]/2範囲内の点に対する中央値は歪んで
% みえる可能性があります。
%
% B = MEDFILT2(A) は、デフォルトの3行3列の近傍を使って、行列 A にメ
% ディアンフィルタリングを行います。
%
% B = MEDFILT2(...,PADOPT) は、どのように行列の境界を付加するかを制御
% します。PADOPT には、'zeros'(デフォルト),'symmetric'、または、
% 'indexed' を設定できます。PADOPT が 'zeros' の場合、A の境界には0
% が付加されます。PADOPT が 'symmetric' の場合、A の境界で対称的に拡張
% されます。PADOPT が 'indexed' で、かつ、A が double の場合、1が付加
% されます。double 以外の場合、0が付加されます。
%
% クラスサポート
% -------------
% 入力イメージ A は、uint8、uint16、または、double の logical です。
% ('indexed' 構文が使われない場合は、A はクラス uint16 をサポートしま
% せん)。出力イメージ B は、A と同じクラスです。
%
% 注意
% ----
% 入力イメージ A が整数クラスの場合、出力値はすべて整数として返されま
% す。近傍内のピクセル数、たとえば、(M*N)が偶数の場合、中央値が整数に
% ならない可能性があります。この場合、小数以下が切り捨てられます。論理
% 配列も同様に処理されます。
%
% 例題
% ----
%       I = imread('eight.tif');
%       J = imnoise(I,'salt & pepper',0.02);
%       K = medfilt2(J);
%       imshow(J), figure, imshow(K)
%
% 参考：FILTER2, ORDFILT2, WIENER2



%   Copyright 1993-2002 The MathWorks, Inc.  
