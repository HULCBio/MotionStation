%  [a,b,c,d,e]=ltiss(sys)
%
%  Extracts the state-space matrices A,B,C,D,E from the SYSTEM
%  matrix representation SYS of the LTI system
%                                        -1
%                G(s)  =  D + C (s E - A)  B
%
%  WARNING:  if the output argument E is omitted, LTISS returns
%            the realization (E\A, E\B, C, D)  of  G(s)
%
%  Input
%    SYS          SYSTEM matrix created with LTISYS
%
%  Output
%    A,B,C,D,E    state-space matrices of SYS
%
%
%  See also  LTISYS, LTITF, SINFO.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [a,b,c,d,e]=ltiss(P)

[rp,cp]=size(P);
if ~islsys(P),
  error('SYS is not a SYSTEM matrix');
end

na=P(1,cp);

a=P(1:na,1:na); b=real(P(1:na,na+1:cp-1));
c=real(P(na+1:rp-1,1:na)); d=real(P(na+1:rp-1,na+1:cp-1));
e=imag(a);  a=real(a);

desc=max(max(abs(e))) > 0;
e=e+eye(na);

if nargout < 5 & desc, a=e\a; b=e\b; end


%  Author: P. Gahinet
