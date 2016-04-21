function mtx = diagmx(Q,R)
%DIAGMX Put matrices on the main diagonal.
%
% MTX = DIAGMX(Q,R) puts the matrices Q and R on the main diagonal.
%       Q & R can be nonsquare.
%

% R. Y. Chiang & M. G. Safonov 1/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------
[mq,nq] = size(Q);
[mr,nr] = size(R);
mtx=zeros(mr+mq,nr+nq);
mtx(1:mq,1:nq)=Q;
mtx(mq+1:end,nq+1:end)=R;
%
% ------- End of DIAGMX.M -- RYC/MGS