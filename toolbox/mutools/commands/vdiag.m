% function out = vdiag(matin)
%
%   Diagonal of a VARYING matrix. Operates just as DIAG
%   does in standard MATLAB, but on VARYING matrices also.
%
%   See also: DIAG, VEBE, and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vdiag(matin)
 if nargin == 0
   disp('usage: out = vdiag(matin)');
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(matin);
 if mtype == 'cons'
   out = diag(matin);
 elseif mtype == 'vary'
   if mrows == 1         % out is mcols x mcols
     nrout = mcols;
     ncout = mcols;
   elseif mcols == 1     % out is mrows x mrows
     nrout = mrows;
     ncout = mrows;
   else                  % out is min([mrows mcols]) x 1
     nrout = min([mrows mcols]);
     ncout = 1;
   end
   out = zeros((mnum*nrout)+1,ncout+1);
   npts = mnum;
   ff = (npts+1)*mrows;
   pt = 1:mrows:ff;
   ptm1 = pt(2:npts+1)-1;
   for i=1:npts
     out((nrout*(i-1)+1):nrout*i,1:ncout) = diag(matin(pt(i):ptm1(i),1:mcols));
   end
   out(1:npts,ncout+1) = matin(1:npts,mcols+1);
   out((mnum*nrout)+1,ncout) = npts;
   out((mnum*nrout)+1,ncout+1) = inf;
 elseif mtype == 'syst'
   error('VDIAG is undefined for SYSTEM matrices');
   return
 else
   out = [];
 end
%
%