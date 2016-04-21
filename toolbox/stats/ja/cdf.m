% CDF   選択された分布の累積分布関数を計算
%
% P = CDF(NAME,X,A1) は、パラメータ A1 を使って、X 内の値で NAME で指定
% された累積分布関数を出力します。
% 
% P = CDF(NAME,X,A1,A2) は、パラメータ A1 と A2 を使って、X の値で NAME 
% で指定された累積分布関数を出力します。P = CDF(NAME,X,A1,A2,A3) も同様
% です。
% 
% 設定可能な分布は、つぎのいずれかです。
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
% CDF は、計算を実行するときに、対応する関数をコールします。 


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:05 $
