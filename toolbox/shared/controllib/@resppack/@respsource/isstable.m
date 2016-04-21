function boo = isstable(this,idx)
%ISSTABLE   Returns 1 for a stable model.
%
%  TF = ISSTABLE(SRC,N) returns 1 if the N-th model is stable, 
%  0 if it is unstable, and NaN for undetermined.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:49 $

boo = NaN;  % undertermined