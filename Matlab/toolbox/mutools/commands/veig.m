% function  eval = veig(mat1,mat2)
%   or
% function  [evect,eval] = veig(mat1,mat2)
%
%   Eigenvalue decomposition of a VARYING matrix.
%     inputs:
%            mat1  - square matrix, CONSTANT/VARYING
%            mat2  - square matrix, CONSTANT/VARYING (optional)
%     outputs:
%	     eval  - vector containing eigenvalues of MAT1,
%                     CONSTANT/VARYING
%	     evect - full matrix containing eigenvectors of MAT1,
%                     CONSTANT/VARYING
%
%   If MAT2 is supplied, a generalized eigenvalue problem is solved.
%
%   See also: EIG, INDVCMP, SVD, VEBE, VPOLY, VROOTS, VSVD, and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2] = veig(mat1,mat2)
  if nargin == 0
    disp('usage: eval = veig(mat1,mat2)')
    disp('   or  [evect,eval] = veig(mat1,mat2)')
    return
  end
  varyflg = 0;
  [mtype1,mrows1,mcols1,mnum1] = minfo(mat1);
  if strcmp(mtype1,'syst')
    error(['VEIG is not defined for SYSTEM matrices']);
    return
  end
  if strcmp(mtype1,'vary')
    varyflg = 1;
  end
  if mrows1 ~= mcols1
    error(['input matrices to VEIG must be square'])
    return
  end
  if nargin == 2
    [mtype2,mrows2,mcols2,mnum2] = minfo(mat2);
    if ~isstr(mat2)
      if strcmp(mtype2,'syst')
        error(['VEIG is not defined for SYSTEM matrices']);
        return
      end
      if mcols2 ~= mrows2
        error(['input matrices to VEIG must be square']);
        return
      end
      if mcols1 ~= mcols2
        error(['matrix dimensions must agree in VEIG']);
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
    else
      if ~strcmp(mat2,'nobalance')
        error(['2nd argument in VEIG should be a matrix or nobalance'])
        return
      end
    end
  end
  mrows = mrows1;
  mcols = mcols1;
  [nr1,nc1] = size(mat1);
  if strcmp(mtype1,'cons')
    if nargin == 1
      if nargout <= 1
        out1 = eig(mat1);
      else
        [out1,out2] = eig(mat1);
      end
    else  % nargin == 2
      if strcmp(mtype2,'cons')
        if nargout <= 1
          out1 = eig(mat1,mat2);
        else
          [out1,out2] = eig(mat1,mat2);
        end
      else                % m2 is VARYING
        indv = mat2(1:mnum2,mcols+1);
        npts = mnum2;
        if nargout <= 1
          nrout = mrows;
          ncout = 1;
          out1 = zeros(npts*mrows,ncout);
          fone = (npts+1)*mrows;
          pone = 1:mrows:fone;
          ponem1 = pone(2:npts+1) - 1;
          for i=1:npts
            out1(pone(i):ponem1(i),1:ncout) = ...
            eig(mat1,mat2(pone(i):ponem1(i),1:mcols));
          end
          out1=vpck(out1,indv);
        else
          nrout = mrows;
          ncout = mrows;
          out1 = zeros(npts*mrows,ncout);
          out2 = zeros(npts*mrows,ncout);
          fone = (npts+1)*mrows;
          pone = 1:mrows:fone;
          ponem1 = pone(2:npts+1) - 1;
          for i=1:npts
            [out1(pone(i):ponem1(i),1:ncout),...
            out2(pone(i):ponem1(i),1:ncout)] = ...
            eig(mat1,mat2(pone(i):ponem1(i),1:mcols));
          end
          out1=vpck(out1,indv);
          out2=vpck(out2,indv);
        end
      end
    end
  else  % m1 is varying
    npts = mnum1;
    indv = mat1(1:mnum1,mcols1+1);
    if nargin == 1
      if nargout <= 1
        nrout = mrows;
        ncout = 1;
        out1 = zeros(npts*mrows,ncout);
        fone = (npts+1)*mrows;
        pone = 1:mrows:fone;
        ponem1 = pone(2:npts+1) - 1;
        for i=1:npts
          out1(pone(i):ponem1(i),1:ncout) = ...
          eig(mat1(pone(i):ponem1(i),1:mcols));
        end
        out1=vpck(out1,indv);
      else
        nrout = mrows;
        ncout = mrows;
        out1 = zeros(npts*mrows,ncout);
        out2 = zeros(npts*mrows,ncout);
        fone = (npts+1)*mrows;
        pone = 1:mrows:fone;
        ponem1 = pone(2:npts+1) - 1;
        for i=1:npts
          [out1(pone(i):ponem1(i),1:ncout),...
          out2(pone(i):ponem1(i),1:ncout)] = ...
          eig(mat1(pone(i):ponem1(i),1:mcols));
        end
        out1=vpck(out1,indv);
        out2=vpck(out2,indv);
      end
    elseif nargin == 2
      if strcmp(mtype2,'cons')
        if nargout <= 1
          nrout = mrows;
          ncout = 1;
          out1 = zeros(npts*mrows,ncout);
          fone = (npts+1)*mrows;
          pone = 1:mrows:fone;
          ponem1 = pone(2:npts+1) - 1;
          for i=1:npts
            out1(pone(i):ponem1(i),1:ncout) = ...
            eig(mat1(pone(i):ponem1(i),1:mcols),mat2);
          end
          out1=vpck(out1,indv);
        else
          nrout = mrows;
          ncout = mrows;
          out1 = zeros(npts*mrows,ncout);
          out2 = zeros(npts*mrows,ncout);
          fone = (npts+1)*mrows;
          pone = 1:mrows:fone;
          ponem1 = pone(2:npts+1) - 1;
          for i=1:npts
            [t,tt] = eig(mat1(pone(i):ponem1(i),1:mcols),mat2);
            out1(pone(i):ponem1(i),1:ncout) = t;
            out2(pone(i):ponem1(i),1:ncout) = tt;
          end
          out1=vpck(out1,indv);
          out2=vpck(out2,indv);
        end
      else                % m2 is VARYING also
        if nargout <= 1
          nrout = mrows;
          ncout = 1;
          out1 = zeros(npts*mrows,ncout);
          fone = (npts+1)*mrows;
          pone = 1:mrows:fone;
          ponem1 = pone(2:npts+1) - 1;
          for i=1:npts
           out1(pone(i):ponem1(i),1:ncout) = ...
           eig(mat1(pone(i):ponem1(i),1:mcols),mat2(pone(i):ponem1(i),1:mcols));
          end
          out1=vpck(out1,indv);
        else
          nrout = mrows;
          ncout = mrows;
          out1 = zeros(npts*mrows,ncout);
          out2 = zeros(npts*mrows,ncout);
          fone = (npts+1)*mrows;
          pone = 1:mrows:fone;
          ponem1 = pone(2:npts+1) - 1;
          for i=1:npts
           [t,tt] = ...
           eig(mat1(pone(i):ponem1(i),1:mcols),mat2(pone(i):ponem1(i),1:mcols));
           out1(pone(i):ponem1(i),1:ncout) = t;
           out2(pone(i):ponem1(i),1:ncout) = tt;
          end
          out1=vpck(out1,indv);
          out2=vpck(out2,indv);
        end
      end
    end
  end
%
%