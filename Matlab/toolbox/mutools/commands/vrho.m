% function out = vrho(matin)
%
%   Spectral radius of a square, VARYING/CONSTANT matrix.
%   The spectral radius is defined as MAX(ABS(EIG(MATIN)))
%   for a CONSTANT matrix and as  MAX(ABS(EIG(XTRACTI(MATIN,I))))
%   for each INDEPENDENT VARIABLE of the VARYING matrix MATIN.
%
%   See also: EIG and VEIG.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vrho(matin)
 if nargin == 0
   disp('usage: out = vrho(matin)');
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(matin);
 if mtype == 'cons'
   if mrows ~= mcols
     error('VRHO is undefined for nonsquare matrices')
     return
   end
   out = max(abs(eig(matin)));
 elseif mtype == 'vary'
   if mrows ~= mcols
     error('VRHO is undefined for nonsquare matrices')
     return
   end
   npts = mnum;
   nrout = mnum;
   ncout = 2;
   out = zeros(npts+1,2);
   ff = (npts+1)*mrows;
   pt = 1:mrows:ff;
   ptm1 = pt(2:npts+1)-1;
   for i=1:npts
     out(i,1) = max(abs(eig(matin(pt(i):ptm1(i),1:mcols))));
   end
   out(1:npts,2) = matin(1:npts,mcols+1);
   out(npts+1,1) = npts;
   out(npts+1,2) = inf;
 elseif mtype == 'syst'
   error('VRHO is undefined for SYSTEM matrices');
   return
 else
  out = [];
 end
%
%