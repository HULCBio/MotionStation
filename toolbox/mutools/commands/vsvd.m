% function [u,s,v] = vsvd(mat)
%
%   Singular value decomposition of a VARYING/CONSTANT
%   matrix, identical to MATLAB's SVD command, but
%   VSVD works with VARYING matrices also.
%
%   See also: COND, EIG, SVD, VCOND, VEIG, and VNORM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2,out3] = vsvd(mat)
  if nargin ~= 1
    disp(['usage: [u,s,v] = vsvd(mat)'])
    return
  end
  if nargout == 2
    error(['incorrect number of output arguments']);
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mtype == 'cons'
    if nargout <= 1
      out1 = svd(mat);
    else
      [out1,out2,out3] = svd(mat);
    end
  elseif mtype == 'vary'
    indv = mat(1:mnum,mcols+1);
    if nargout <= 1
      npts = mnum;
      nrout = min([mrows mcols]);
      ncout = 1;
      out = zeros((nrout*npts)+1,ncout+1);
      out1((nrout*npts)+1,ncout+1) = inf;
      out1((nrout*npts)+1,ncout) = npts;
      out1(1:npts,ncout+1) = indv;
      for i=1:npts
        out1((i-1)*nrout+1:i*nrout,1:ncout) = ...
             svd(mat((i-1)*mrows+1:i*mrows,1:mcols));
      end
    else
      npts = mnum;
      nrout1 = mrows; ncout1 = mrows;
      nrout2 = mrows; ncout2 = mcols;
      nrout3 = mcols; ncout3 = mcols;
      out1 = zeros(nrout1*npts,ncout1);
      out2 = zeros(nrout2*npts,ncout2);
      out3 = zeros(nrout3*npts,ncout3);
      out1((nrout1*npts)+1,ncout1+1) = inf;
      out1((nrout1*npts)+1,ncout1) = npts;
      out1(1:npts,ncout1+1) = indv;
      out2((nrout2*npts)+1,ncout2+1) = inf;
      out2((nrout2*npts)+1,ncout2) = npts;
      out2(1:npts,ncout2+1) = indv;
      out3((nrout3*npts)+1,ncout3+1) = inf;
      out3((nrout3*npts)+1,ncout3) = npts;
      out3(1:npts,ncout3+1) = indv;
      for i=1:npts
        [tu,ts,tv] = svd(mat((i-1)*mrows+1:i*mrows,1:mcols));
        out1((i-1)*nrout1+1:i*nrout1,1:ncout1) = tu;
        out2((i-1)*nrout2+1:i*nrout2,1:ncout2) = ts;
        out3((i-1)*nrout3+1:i*nrout3,1:ncout3) = tv;
      end
    end
  elseif mtype == 'syst'
    error('VSVD is undefined for SYSTEM matrices')
    return
  end
%
%