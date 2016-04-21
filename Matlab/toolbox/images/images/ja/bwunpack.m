% BWUNPACK  バイナリイメージのパックの解除
% BW = BWUNPACK(BWP,M) は、パックされたバイナリイメージ BWP のパック状
% 態を解除します。BWP は、uint32 配列です。BWP パック状態を解除する場合、
% BWUNPACK は、BWP の最初の行の最小ビットをBW の最初の行の中の最初のピク
% セルにマッピングします。BWP の最初の要素の最大ビットは、BW の32番目の
% 最初のピクセルにマッピングされ、同様にして、すべてがマッピングされます。
% BW は、M 行 N 列です。ここで、N は、BWP の列数です。M を省略すると、
% デフォルトの 32*SIZE(BWP,1) を使います。
%
% バイナリイメージのパック化は、膨張や縮退のようないくつかのバイナリ形
% 態学的演算を高速にするために使われます。IMDILATE や IMERODE への入力
% が、パックされたバイナリイメージの場合、関数は、特別な関数に使われ、
% 演算を高速にします。 
%
% BWNPACK は、バイナリイメージをパックするために使います。
%
% クラスサポート
% -------------
% BMP は、uint32 で、また実数で2次元の非スパースでなければなりません。
% BW は logical です。
%
% 例題
% -------
% バイナリイメージをパック、膨張、パックの解除を行います。
%
%       bw = imread('text.tif');
%       bwp = bwpack(bw);
%       bwp_dilated = imdilate(bwp,ones(3,3),'ispacked');
%       bw_dilated = bwunpack(bwp_dilated, size(bw,1));
%
% 参考：BWPACK, IMDILATE, IMERODE.



%   Copyright 1993-2002 The MathWorks, Inc.
