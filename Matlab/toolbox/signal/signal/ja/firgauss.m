% FIRGAUSS FIR Gaussian デジタルフィルタ設計
% B = FIRGAUSS(K,N) は、FIR フィルタの設計をします。このインパルス応答
% は、理想的なガウス分布を近似します。このフィルタは長さN の 
% cascading K uniform-coefficient (boxcar) フィルタにより実現されます。
% フィルタ全体のインパルス応答の長さは、K*(N-1)+1です。
% フィルタの係数は、ベクトルBに出力されます。
%
% [B, N] = FIRGAUSS(K,'minorder',V) は、分散Vをもつガウスフィルタを
% 設計します。標準偏差の二乗として定義される、この分散は、個々のboxcar
% フィルタのコンボリューション(カスケード)の分散の和です。
% K >= 4の場合、FIRGAUSSは、各boxcar フィルタの長さN を決定するために、 
% 最適なテクニックを使用します。この最適なテクニックは、フィルタのインパルス
% 応答と、理想的なガウス分布との間の二乗平均平方根(rms)の差を最小にするガウス
% 近似になります。 
%
% 例題:
%   % 長さ32の4 boxcar フィルタのカスケード
%   K = 4; N = 32;    
%   b = firgauss(K,N); 
%   fvtool(b);
%
% 参考 GAUSSWIN, GAUSPULS, GMONOPULS. 

%   Copyright 1988-2002 The MathWorks, Inc.
