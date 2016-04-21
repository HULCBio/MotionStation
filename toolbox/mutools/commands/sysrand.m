% function out = sysrand(nstates,noutputs,ninputs,flg_stab)
%
%  Create a random SYSTEM matrix (using a normally distributed set
%   of random numbers), with a specified number of states,
%   inputs and outputs. Setting FLG_STAB = 1 results in a stable,
%   random SYSTEM matrix. (Default is FLG_STAB = 0.)
%
%   See also: CRAND, CRANDN, MINFO, PCK, PSS2SYS,
%             SYS2PSS, RAND, and RANDEL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function out = sysrand(n,nout,nin,flg_stab)

 if nargin < 3
   disp(['usage: out = sysrand(nstates,noutputs,ninputs,flg_stab)'])
 else
   if min([n nin nout]) <= 0
     error('dimensions should be positive')
   elseif ceil([n nin nout]) == floor([n nin nout])
     if nargin == 3
       out = pck(randn(n,n),randn(n,nin),randn(nout,n),randn(nout,nin));
     else
       if flg_stab == 1
         a = randn(n,n);
         mreig = max(real(eig(a)));
	 if mreig > 0
            a = a - 1.2*max(real(eig(a)))*eye(n,n);
	 end
         out = pck(a,randn(n,nin),randn(nout,n),randn(nout,nin));
       else
         out = pck(randn(n,n),randn(n,nin),randn(nout,n),randn(nout,nin));
       end
     end
   else
     error('dimensions should be integers')
   end
 end
%
%