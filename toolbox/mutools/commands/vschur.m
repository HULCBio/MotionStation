% function [u,t] = vschur(mat)
%
%   Schur decomposition of a VARYING/CONSTANT matrix,
%   identical to MATLAB's SCHUR command, but VSCHUR
%   works with VARYING matrices also.
%     input:
%	     MAT - VARYING/CONSTANT matrix
%     outputs:
%	     U   - unitary matrix, VARYING/CONSTANT matrix
%                   MAT = MMULT(U,T,TRANSP(U)), and  MMULT(TRANSP(U),U)
%		    is the identity of the corresponding type.
%            T   - complex or real Schur form depending on the
%		    input, VARYING/CONSTANT matrix.
%
%   See also: CSORD, EIG, RSF2CSF, SCHUR, SVD, VEIG and VSVD.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1,out2] = vschur(mat)
  if nargin ~= 1
    disp(['usage: [u,t] = vschur(mat)'])
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mcols ~= mrows
    error(['input to VSCHUR should be square']);
    return
  end
  if mtype == 'cons'
    if nargout <= 1
      out1 = schur(mat);
    else
      [out1,out2] = schur(mat);
    end
  elseif mtype == 'vary'
    indv = mat(1:mnum,mcols+1);
    if nargout <= 1
      npts = mnum;
      nrout = mrows;
      ncout = mcols;
      out = zeros((nrout*npts)+1,ncout+1);
      fone = (npts+1)*mrows;
      pone = 1:mrows:fone;
      ponem1 = pone(2:npts+1) - 1;
      for i=1:npts
        out1(pone(i):ponem1(i),1:mcols) = ...
             schur(mat(pone(i):ponem1(i),1:mcols));
      end
      out1((nrout*npts)+1,ncout+1) = inf;
      out1((nrout*npts)+1,ncout) = npts;
      out1(1:npts,ncout+1) = indv;
    else
      npts = mnum;
      nrout = mrows;
      ncout = mcols;
      out1 = zeros(nrout*npts+1,ncout+1);
      out2 = zeros(nrout*npts+1,ncout+1);
      out1((nrout*npts)+1,ncout+1) = inf;
      out1((nrout*npts)+1,ncout) = npts;
      out1(1:npts,ncout+1) = indv;
      out2((nrout*npts)+1,ncout+1) = inf;
      out2((nrout*npts)+1,ncout) = npts;
      out2(1:npts,ncout+1) = indv;
      fout = (npts+1)*nrout;
      pout = 1:mrows:fout;
      poutm1 = pout(2:npts+1) - 1;
      for i=1:npts
        [tu,ts] = schur(mat(pout(i):poutm1(i),1:mcols));
        out1(pout(i):poutm1(i),1:ncout) = tu;
        out2(pout(i):poutm1(i),1:mcols) = ts;
      end
    end
  elseif mtype == 'syst'
    error('VSCHUR is undefined for SYSTEM matrices')
    return
  end
%
%