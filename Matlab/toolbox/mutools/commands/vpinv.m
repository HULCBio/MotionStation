% function out = vpinv(mat,tol)
%
%   Pseudo-inverse of a VARYING/CONSTANT matrix.
%   Identical to MATLAB's PINV command. The default
%   value for TOL is 1e-12.
%
%   See also: INV, MINV, PINV, and VINV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vpinv(mat,tol)
  if nargin == 0
    disp('usage: out = vpinv(mat,tol)')
    return
  end
  if nargin == 1
    tol = 1e-12;
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  [nr,nc] = size(mat);
  if mtype == 'cons'
    if nargin == 1
      out = pinv(mat);
    else
      out = pinv(mat,tol);
    end
  elseif mtype == 'vary'
    indv = mat(1:mnum,nc);
    npts = mnum;
    nrout = mcols;
    ncout = mrows;
    out = zeros(nrout*npts+1,ncout+1);
    out(nrout*npts+1,ncout+1) = inf;
    out(1:mnum,ncout+1) = indv;
    out(nrout*npts+1,ncout) = npts;
    fftop = (npts+1)*mcols;
    pptop = 1:mcols:fftop;
    pptopm1 = pptop(2:npts+1) - 1;
    ftop = (npts+1)*mrows;
    ptop = 1:mrows:ftop;
    ptopm1 = ptop(2:npts+1) - 1;
    for i=1:npts
      if nargin == 1
        out(pptop(i):pptopm1(i),1:ncout) = ...
        pinv(mat(ptop(i):ptopm1(i),1:mcols));
      else
        out(pptop(i):pptopm1(i),1:ncout) = ...
        pinv(mat(ptop(i):ptopm1(i),1:mcols),tol);
      end
    end
  elseif mtype == 'syst'
    error(['VPINV is undefined for SYSTEM matrices']);
    return
  end
%
%