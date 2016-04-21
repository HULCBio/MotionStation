% PDF   選択した確率密度関数を計算
%
% Y = PDF(NAME,X,A) は、パラメータ A を使って、X の値で名前を指定した
% 確率密度関数値を出力します。
%
% Y = PDF(NAME,X,A,B,) は、パラメータ A と B をもつ X の値でで、名前を
% 指定した確率密度関数値を出力します。Y = PDF(NAME,X,A,B,C) に対しても
% 同様です。
% 
% 指定可能な分布名は、つぎのいずれかです。
% 'beta', 'Beta'
% 'bino', 'Binomial'
% 'chi2', 'Chisquare'
% 'exp', 'Exponential',
% 'ev', 'Extreme Value', 
% 'f', 'F'
% 'gam', 'Gamma'
% 'geo', 'Geometric',
% 'hyge', 'Hypergeometric'
% 'logn', 'Lognormal' 
% 'nbin', 'Negative Binomial'
% 'ncf', 'Noncentral F' 
% 'nct', 'Noncentral t'
% 'ncx2', 'Noncentral Chi-square'
% 'norm', 'Normal'
% 'poiss', 'Poisson'
% 'rayl', 'Rayleigh'
% 't', 'T'
% 'unif', 'Uniform'
% 'unid', 'Discrete Uniform'
% 'wbl', 'Weibull'
% 
% PDF は、計算を実行するとき、対応するルーチンをコールします。


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:03 $
