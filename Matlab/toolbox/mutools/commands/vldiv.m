% function  out = vldiv(mat1,mat2)
%
%   Left division for VARYING/CONSTANT matrices. Identical
%   to the MATLAB \ command, but works on VARYING matrices
%   as well. MAT1\MAT2
%
%   See also: \, /, INV, MINV, VINV, and VRDIV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vldiv(mat1,mat2)
  if nargin ~= 2
    disp('usage: out = vldiv(mat1,mat2)')
    return
  end
  varyflg = 0;
  [mtype1,mrows1,mcols1,mnum1] = minfo(mat1);
  [mtype2,mrows2,mcols2,mnum2] = minfo(mat2);
  if strcmp(mtype1,'syst')
    error(['VLDIV is not defined for SYSTEM matrices']);
    return
  end
  if strcmp(mtype2,'syst')
    error(['VLDIV is not defined for SYSTEM matrices']);
    return
  end
  if strcmp(mtype1,'vary')
    varyflg = 1;
  end
  if mrows1 ~= mrows2
    error(['input matrices to VLDIV must have same number of rows']);
    return
  end
  if strcmp(mtype2,'vary')
    if varyflg == 1
      code = indvcmp(mat1,mat2);
      if code ~= 1
         error(['inconsistent varying data'])
         return
      end
    else
      varyflg = 1;
    end
  end
  nrout = mcols1;
  ncout = mcols2;
  if strcmp(mtype1,'cons')
    if strcmp(mtype2,'cons')
      out = mat1\mat2;
    else                % m2 is VARYING
      indv = mat2(1:mnum2,mcols2+1);
      npts = mnum2;
      out = zeros(npts*nrout+1,ncout+1);
      out(npts*nrout+1,ncout+1) = inf;
      out(npts*nrout+1,ncout) = npts;
      out(1:npts,ncout+1) = indv;
      fone = (npts+1)*mrows2;
      pone = 1:mrows2:fone;
      ponem1 = pone(2:npts+1) - 1;
      for i=1:npts
         out((i-1)*nrout+1:nrout*i,1:ncout) = ...
         mat1\mat2(pone(i):ponem1(i),1:mcols2);
      end
    end
  else  % m1 is varying
    npts = mnum1;
    indv = mat1(1:mnum1,mcols1+1);
    if strcmp(mtype2,'cons')
      out = zeros(npts*nrout+1,ncout+1);
      out(npts*nrout+1,ncout+1) = inf;
      out(npts*nrout+1,ncout) = npts;
      out(1:npts,ncout+1) = indv;
      fone = (npts+1)*mrows1;
      pone = 1:mrows1:fone;
      ponem1 = pone(2:npts+1) - 1;
      for i=1:npts
        out((i-1)*nrout+1:nrout*i,1:ncout) = ...
        mat1(pone(i):ponem1(i),1:mcols1)\mat2;
      end
    else
      out = zeros(npts*nrout+1,ncout+1);
      out(npts*nrout+1,ncout+1) = inf;
      out(npts*nrout+1,ncout) = npts;
      out(1:npts,ncout+1) = indv;
      fone = (npts+1)*mrows1;
      pone = 1:mrows1:fone;
      ponem1 = pone(2:npts+1) - 1;
      for i=1:npts
       out((i-1)*nrout+1:nrout*i,1:ncout) = ...
       mat1(pone(i):ponem1(i),1:mcols1)\mat2(pone(i):ponem1(i),1:mcols2);
      end
    end
  end
%
%