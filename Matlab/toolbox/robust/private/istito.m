function [tito,U1,U2,Y1,Y2]=istito(sys)
% [TITO,U1,U2,Y1,Y2]=ISTITO(SYS) tests whether a system has at
%    least two InputGroup and two OutputGroup channels.
%    If not, it returns TITO=0 (false); otherwise, TITO=1 (true)
%    is returned along with TITO channel indices in row vectors:
%        U1 = first input channel indices
%        U2 = second input channel indices
%        Y1 = first output channel indices
%        Y2 = second output channel indices
%
%  See also MKTITO

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.4 $
% All rights reserved.

% Based on Gahinet's 1/98 partitioning specification:

% Initialize output variables:
tito=logical(1);
U1=[]; U2=[]; Y1=[]; Y2=[];

ip=get(sys,'InputGroup');
op=get(sys,'OutputGroup');

if isstruct(ip)
    ip=struct2cell(ip);
    op=struct2cell(op);
end

[rip,cip]=size(ip);
[rop,cop]=size(op);
if rip<2 | rop<2,
   tito=logical(0);   % no InputGroup present,
   return             % so set TITO=0 and exit
else
   tito=logical(1);
end

% quick return if U1 & U2 not needed
if nargout<2, 
   return 
end

U1=ip{1,1};
U2=ip{2,1};
Y1=op{1,1};
Y2=op{2,1};
    
% ----------- End of ISTITO.M --------RYC/MGS 1997

