function scale = logscale(LB,UB,meanX)
%LOGSCALE: Used to determine the scaling factor for mesh

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2004/01/16 16:49:52 $

%The following is a guideline for scaling variables.

%meanX, LB and UB could be (in)finite and (non)zero. Scaling will be different in each case. 
LowUpFiniteNonzero = (isfinite(LB) & abs(LB)>=eps) & (isfinite(UB)  & abs(UB)>=eps);
LowFiniteNonZero   = (isfinite(LB) & abs(LB)>=eps) & (~isfinite(UB) | abs(UB)<=eps);
UpFiniteNonZero    = (~isfinite(LB)| abs(LB)<=eps) & (isfinite(UB)  & abs(UB)>=eps);
InfiniteZero       = (~isfinite(LB)| abs(LB)<=eps) & (~isfinite(UB) | abs(UB)<=eps);
%Calculate LOG scale (Dennis & Schnabel)
lscale = zeros(length(meanX),1);
lscale(LowUpFiniteNonzero) = (log2(abs(LB(LowUpFiniteNonzero)))+log2(abs(UB(LowUpFiniteNonzero))))/2;
lscale(LowFiniteNonZero)   =  log2(abs(LB(LowFiniteNonZero)));
lscale(UpFiniteNonZero)    =  log2(abs(UB(UpFiniteNonZero)));

if abs(meanX(InfiniteZero))>=eps
lscale(InfiniteZero)       =  log2(abs(meanX(InfiniteZero)));
end
%Convert to normal scale.
scale = 2.^round(lscale);


