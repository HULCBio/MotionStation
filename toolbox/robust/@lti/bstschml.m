function [ahed,bhed,ched,dhed,aug,hsv] = bstschml(varargin)
%BSTSCHML Balanced stochastic truncation (BST) model reduction.
%
% [SS_H,AUG,HSV] = BSTSCHML(SS_,MRTYPE,NO,INFO) or
% [AHED,BHED,CHED,DHED,AUG,HSV]=BSTSCHML(A,B,C,D,MRTYPE,NO,INFO) performs
%    relative error Schur model reduction on a SQUARE, STABLE G(s):=
%    (A,B,C,D). The infinity-norm of the relative error is bounded as
%                             -1               n
%            |(Gm(s)-G(s))Gm(s) |    <= 2 * ( SUM  si / (1 - si) )
%                                inf          k+1
%    where si denotes the i-th Hankel singular value of the all-pass
%    "phase matrix" of G(s).
%    The algorithm is based on the Balanced Stochastic Truncation (BST)
%    theory with Relative Error Method (REM).
%    Based on the "MRTYPE" selected, you have the following options:
%     1). MRTYPE = 1  --- no: size "k" of the reduced order model.
%     2). MRTYPE = 2  --- find k-th order reduced model that
%                         tolerance (db) <= "no".
%     3). MRTYPE = 3  --- display all the Hankel SV of phase matrix and
%                   prompt for "k" (in this case, no need to specify "no").
%    Input variable: "info" = 'left '(default is also 'left ').
%    Output variable "aug": aug(1,1) = no. of state removed
%                           aug(1,2) = relative error bound
%    Note that if D is not full rank, an error will result.

% R. Y. Chiang & M. G. Safonov 2/30/88
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% ------------------------------------------------------------------------

nag1 = nargin;
[emsg,nag1,xsflag,Ts,A,B,C,D,mrtype,no,info]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end
nag1 = nargin;  % NARGIN may have been changed.

if nag1 <= 6
   info = 'left ';
end
if mrtype == 3
   no = NaN;
end
[ahed,bhed,ched,dhed,aug,hsv] = bstschmr(A,B,C,D,mrtype,no,info);
%
if xsflag
   ahed = mksys(ahed,bhed,ched,dhed);
   bhed = aug;
   ched = hsv;
end
%
% ------- End of BSTSCHML.M --- RYC/MGS 9/13/87 %
