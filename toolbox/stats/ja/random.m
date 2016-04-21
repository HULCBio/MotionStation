% RANDOM   指定した分布からの乱数を発生
%
% 利用する分布のパラメータ数に依存して文法が変化します。
%
% R = RANDOM(NAME,A,M,N) は、パラメータ A をもつ指定した分布から M行N列の
% 乱数行列を出力します。
% R = RANDOM(NAME,A,B,M,N) は、パラメータ A と B をもつ指定した分布から 
% M行N列の乱数行列を出力します。
% R = RANDOM(NAME,A,B,C,M,N) は、パラメータ A, B, C をもつ指定した分布
% からM行N列の乱数行列を出力します。
% 
% 指定可能な分布は、つぎのものです。
% 'beta', 'Beta'
% 'bino', 'Binomial'
% 'chi2', 'Chisquare'
% 'exp', 'Exponential',
% 'ev', 'Extreme Value'
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
% M と N は、共に整数です。また、N を省略して、2つの整数のベクトルとして
% M を指定しても構いません。M と N の両方を省略した場合、R は、1行1列の
% 配列になります。


%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:15:11 $
