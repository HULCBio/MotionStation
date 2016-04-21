% function [q,gammaopt] = ruqvsol(r,u,v)
%
% これは、Davis-Kahan-Weinberger問題の定数行列を解きます(SIAM Journal, 
% 1981)。
%
% gammaopt := min norm(r + u*q*v)
%              q
%
% これは、現代線形システム理論の中で最も重要な線形代数補題の1つです。19
% 82年から1987年までのH∞の研究のoperator-theoreticバージョンと1990年か
% ら現在までのAMIベースのシンセシス手法に示されています。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:35 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
