% ICDF   選択した逆累積分布関数
%
% X = ICDF(NAME,P,A) は、パラメータ A を使い、X の値での逆累積分布関数
% を出力します。
% 
% X = ICDF(NAME,P,A,B) は、パラメータ A と B で設定されている指定した
% 累積分布の X での値を出力します。X = ICDF(NAME,P,A,B,C) も同様に、
% パラメータ A, B, C で設定されている指定した累積分布の X での値を出力
% します。
% 
% 指定できる分布は、つぎのいずれかです。
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
% ICDF は、計算を行うのに多くの特別なルーチンをコールします。


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:20 $
