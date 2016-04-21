% FREQSPACE   周波数応答のための等間隔の周波数
% 
% FREQSPACEは、等間隔の周波数応答を求めるための周波数の範囲を出力します。
% FREQSPACEは、種々の1次元アプリケーションと同様、FSAMP2、FWIND1、FWIND2
% に対する周波数応答を作成するのに役立ちます。
% 
% [F1,F2] = FREQSPACE(N)は、N行N列の行列に対する2次元周波数ベクトルF1と
% F2を出力します。
% [F1,F2] = FREQSPACE([M N])は、M行N列の行列に対する2次元周波数ベクトル
% を出力します。
%
% 2次元ベクトルでnが奇数の場合、F = (-1+1/n:2/n:1-1/n)です。
% 2次元ベクトルでnが偶数の場合、F = (-1    :2/n:1-2/n)です。
%
% [F1,F2] = FREQSPACE(...,'meshgrid')は、[F1,F2] = freqspace(...); 
% [F1,F2] = meshgrid(F1,F2)と等価です。
%
% F = FREQSPACE(N)は、単位円周上の等間隔のN個の点を仮定して、1次元周波数
% ベクトルFを出力します。1次元ベクトルに対して、F = (0:2/N:1)です。F = 
% FREQSPACE(N,...'whole')は、等間隔のN個の点を出力します。この場合、F = 
% (0:2/N:2*(N-1)/N)です。
%
% 参考：FSAMP2, FWIND1, FWIND2 (Image Processing Toolbox).


%   Clay M. Thompson 1-11-93
%   Copyright 1984-2003 The MathWorks, Inc. 
