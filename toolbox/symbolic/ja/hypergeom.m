% HYPERGEOM は、ガウスの超幾何関数です。
% HYPERGEOM(N, D, Z) は、一般化超幾何関数 F(N, D, Z) で、jFk で定義され
% る Barnes 拡張超幾何関数としても知られています。ここで、j = length(N) 
% で、k = length(D) です。スカラ a, b, c に対して、HYPERGEOM([a,b], c, z)
% は、ガウス超幾何関数 2F1(a, b;c;z) になります。
% 
% 正式なベキ級数の定義は、つぎのようになります。
% 
%    hypergeom(N,D,z) = sum(k=0:inf, (C(N,k)/C(D,k))*z^k/k!) 
% 
% ここで、C(V,k) = prod(i=1:length(V), gamma(V(i)+k)/gamma(V(i))) となり
% ます。最初の2つの引数のどちらも、単一関数計算に対する係数パラメータを
% 与えるベクトルです。3番目の引数がベクトルの場合、関数は、区分的に評価
% されます。結果は、すべての引数が数値の場合、数値になり、引数のいずれか
% が数式の場合、結果は数式になります。Abramowitz と Stegun 著の Handbook
% of Mathematical Functions の15章を参照してください。
% 
% 例題：
%    hypergeom([],[],'z')             は、exp(z) を出力します。
%    hypergeom(1,[],'z')              は、-1/(-1+z) を出力します。
%    hypergeom(1,2,'z')               は、(exp(z)-1)/z を出力します。
%    hypergeom([1,2],[2,3],'z')       は、-2*(-exp(z)+1+z)/z^2 を出力し
%                                     ます。
%    hypergeom('a',[],'z')            は、(1-z)^(-a) を出力します。
%    hypergeom([],1,'-z^2/4')         は、besselj(0,z) を出力します。
%    hypergeom([-n, n],1/2,'(1-z)/2') は、T(n,z) を出力します。ここで、
%    T(n,z) = expand(cos(n*acos(z)))  は、n-次のシェビシェフ多項式です。
%
% 参考： sym/hypergeom.

%   Copyright 1993-2000 The MathWorks, Inc. 
