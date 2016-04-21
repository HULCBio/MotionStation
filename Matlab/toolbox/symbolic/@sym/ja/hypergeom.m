% HYPERGEOM  一般双曲線幾何関数
% HYPERGEIM(N, D, Z)は、Barnes の一般超幾何関数として知られ、j = lenght
% (N) です。k = length(D) のとき jFk として示される幾何関数 F(N, D, Z) 
% を作成します。スカラー a, b, c に対して、HYPERGEOM([a, b], c, z)は、ガ
% ウス超幾何関数 2F1(a, b;c;z) となります。
% 
% 形式的なべき級数による定義は、つぎのようになります。
%  
%     hypergeom(N, D, z) = sum(k=0:inf, (C(N,k)/C(D,k))*z^k/k!) 
%   
% ここで、 C(V, k) = prod(i=1:length(V), gamma(V(i)+k)/gamma(V(i))) です。
% はじめの2つの引数のどちらかは、単関数を評価する係数パラメータを得るた
% めのベクトルになります。3番目の引数がベクトルの場合、関数は点として評
% 価されます。すべての引数が数値の場合、結果は数値になり、すべての引数が
% シンボリック式の場合、結果はシンボリック式になります。
% 
% Abramowitz and Stegun, Handbook of Mathematical Functions, chapter 15 
% を参照してください。
%
% 例題：
%    syms a z
%    hypergeom([],[],z) は、exp(z)  を出力します。
%    hypergeom(1,[],z) は、-1/(-1+z) を出力します。
%    hypergeom(1,2,z) は、(exp(z)-1)/z を出力します。
%    hypergeom([1,2],[2,3],z) は、-2*(-exp(z)+1+z)/z^2 を出力します。
%    hypergeom(a,[],z) は、(1-z)^(-a) を出力します。
%    hypergeom([],1,-z^2/4) は、 besselj(0,z) を出力します。
%    hypergeom([-n, n],1/2,(1-z)/2) は、T(n,z) を出力します。ここで、
%    T(n,z) = expand(cos(n*acos(z))) は、n-次の シビシェフ多項式です。



%   Copyright 1993-2002 The MathWorks, Inc.
