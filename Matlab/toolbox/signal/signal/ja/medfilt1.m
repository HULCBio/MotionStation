% MEDFILT1  1次元メディアンフィルタリング
%
% Y = MEDFILT1(X,N)は、次数 N の1次元メディアンフィルタをベクトル X に適
% 用します。Y は、X と同じ長さです。この関数は、ベクトル X の範囲外では0
% と仮定します。X が行列の場合、MEDFILT1は、X の列に従って動作します。
%
% Nが奇数の場合、Y(k) は、X( k-(N-1)/2 : k+(N-1)/2) の中央値になります。
% Nが偶数の場合、Y(k) は、X( k-N/2 : k+N/2-1) の中央値になります。
%
% N を指定しない場合、デフォルトで N = 3 に設定されます。
%
% MEDFILT1(X,N,BLKSZ) は、for ループを使って、同時に BLKSZ ("ブロックサ
% イズ")個の出力サンプルを計算します。MEDFILT1は、N行BLKSZ 列の作業用行
% 列を使用するため、計算機のメモリが少ない場合には、BLKSZ << LENGTH(X)を
% 使用してください。デフォルトでは、BLKSZ ==  LENGTH(X)です。これは、メ
% モリが十分にある場合に実行時間が最も速くなる設定です。
%
% N次元の行列の場合、Y = MEDFILT1(X,N,[],DIM)、あるいは、Y = MEDFILT(X,N,
% BLKSZ,DIM)は、次元DIMに従って動作します。
%
% 参考：   MEDIAN, FILTER, SGOLAYFILT, MEDFILT2(Image Processing Toolbox
%          の関数)



%   Copyright 1988-2002 The MathWorks, Inc.
