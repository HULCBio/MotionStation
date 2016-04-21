% OPTKNT   補間に対する最適な節点の区分
%
% OPTKNT(TAU,K) は、次数 K のスプラインによるデータサイト 
% TAU(1), ..., TAU(n) での補間に対して、'最適な' 節点列を出力します。
% TAU は増加列でなければなりませんが、これはチェックされません。
%
% OPTKNT(TAU,K,MAXITER) は、試行される繰り返しの数 MAXITER を指定します。
% デフォルトは、10です。
%
% この節点列の内部節点は、節点列 TAU をもつ、K次のすべてのスプライン
% f に対して、
%
%          integral{ f(x)h(x) : TAU(1) < x < TAU(n) } = 0
%
% を満足する、絶対値が一定の関数 h(~= 0) におけるn-K個の符号変化です。
%
% 例題:
% Micchelli/Rivlin/WinogradとGaffney/Powellは、与えられたデータ x, y 
% の次数 K のスプライン補間を作成するつぎの方法を証明しています。
%
%      x = sort([0, rand(1,11)*(2*pi),2*pi]); y = sin(x); k = 5;
%      sp = spapi(optknt(x,k),x,y);
%      fnplt(sp), hold on, plot(x,y,'o'), hold off
%
% 参考 : APTKNT, NEWKNT, AVEKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
