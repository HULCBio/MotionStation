% function out = transp(mat)
%
%   Transpose a VARYING matrix, or  dual of a SYSTEM matrix
%
%   See also: ', .', CJT, VTP, and VCJT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = transp(mat)
 if nargin ~= 1
   disp('usage: out = transp(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   [nr,nc] = size(mat);
   omega = mat(1:mnum,nc);
   npts = mnum;
   nrout = mcols;
   ncout = mrows;
   out = zeros(nrout*npts+1,ncout+1);
   out(nrout*npts+1,ncout+1) = inf;
   out(nrout*npts+1,ncout) = npts;
   out(1:npts,ncout+1) = omega;

   fone = (npts+1)*mrows;
   fout = (npts+1)*nrout;
   pone = 1:mrows:fone;
   pout = 1:nrout:fout;
   ponem1 = pone(2:npts+1) - 1;
   poutm1 = pout(2:npts+1) - 1;
   for i=1:npts
     out(pout(i):poutm1(i),1:ncout) = ...
         mat(pone(i):ponem1(i),1:mcols).';
   end
 elseif mtype == 'syst'
   [a,b,c,d] = unpck(mat);
   out = pck(a.',c.',b.',d.');
 elseif mtype == 'cons'
   out = mat.';
 else
   out = [];
 end
%
%