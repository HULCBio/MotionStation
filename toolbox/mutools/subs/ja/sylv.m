% function X = sylv(A,B,C)
%
% SYLV(A,B,C)は、Sylvester方程式A*X+X*B=Cを解きます。この手法は、Krone-
% cker積を使って、単一ベクトル方程式を生成します。これは、通常は効率的で
% はありませんが、AまたはBが小さい次元(たとえば2)で、もう一方がHessenb-
% ergまたはSchur型であるときには効率的です。
%
% 参考: AXXBC

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:55 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
