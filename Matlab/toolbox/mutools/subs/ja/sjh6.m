% function u = sjh6(a,c)
%
% Lyapunov方程式a'*x + x*a + c'*c = 0を解きます。出力解は、Cholesky因子u
% で、uは上三角行列で、x = u'*uです。
%
% 1987年6月にGloverにより修正されました。
% a が、上Schur型と仮定されます。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:49 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
