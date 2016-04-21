% function smp = extsmp(sys)
%
% つぎのような安定最小位相SYSTEM行列SMPを計算します。
%
%   MMULT(CJT(SMP),SMP) = MMULT(CJT(SYS),SYS)
%
% SYSは、s = jwにおいて、列がフルランクであり、s = jwで極をもちません。
%

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:20 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
