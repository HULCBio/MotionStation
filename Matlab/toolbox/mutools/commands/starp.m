% function out = starp(top,bot,dim1,dim2)
%
%   Redheffer star-product of two SYSTEM/VARYING/CONSTANT
%   matrices. TOP represents the top matrix and BOT represents
%   the bottom matrix. DIM1 is the number of inputs to connect
%   to the BOT matrix and DIM2 is the number of outputs to the
%   TOP matrix. DIM1 and DIM2 are optional, if they are not
%   provided it is assumed that the desired interconnection
%   is a linear fractional transformations and the correct
%   inputs/outputs are closed.
%
%                _________
%       <-------|         |<--------
%               |   TOP   |
%           /---|_________|<---
%      dim1 |                 | dim2
%           |                 |
%           |                 |                 /---------\
%            \________________|___       <------|         |<-------
%                             |  |              |   OUT   |
%                             |  |       <------|         |<-------
%            _________________|  |              \_________/
%           /                    |
%           |   __________       |
%           |--|          |<-----/
%              |   BOT    |
%       <------|__________|<-------
%
%
%   See also: MADD, MMULT, and SYSIC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = starp(mat1,mat2,dim1,dim2)
  if nargin < 2 | nargin == 3
    disp('usage: out = starp(top,bot,dim1,dim2)')
    return
  else
    [onetype,onerows,onecols,onenum] = minfo(mat1);
    [twotype,tworows,twocols,twonum] = minfo(mat2);
    if nargin == 2
      if onerows > twocols
        if tworows >= onecols
          error(['incorrect dimensions']);
          return
        else
          dim1 = twocols;
          dim2 = tworows;
        end
      elseif onerows == twocols
        if onecols == tworows
          dim1 = onerows;
          dim2 = onecols;
        else
          error(['incorrect dimensions']);
        end
      else
        if tworows > onecols
          dim1 = onerows;
          dim2 = onecols;
        else
          error(['incorrect dimensions']);
        end
      end
    end
    if (onetype == 'syst' & twotype == 'vary') | ...
         (onetype == 'vary' & twotype == 'syst')
      error('star product of system and varying not allowed')
      return
    elseif dim1 > min([onerows twocols])
      error('incompatible dimensions')
      return
    elseif dim2 > min([onecols tworows])
      error('incompatible dimensions')
      return
    end
    if onetype == 'vary'
      if twotype == 'vary'
%       both VARYING
        code = indvcmp(mat1,mat2);
        if code == 1
          [nr1,nc1] = size(mat1);
          [nr2,nc2] = size(mat2);
          omega1 = mat1(1:onenum,nc1);
          omega2 = mat2(1:twonum,nc2);
          npts = onenum;
          nrout = onerows + tworows - dim1 - dim2;
          ncout = onecols + twocols - dim1 - dim2;
          out = zeros(nrout*npts+1,ncout+1);
          out(nrout*npts+1,ncout+1) = inf;
          out(nrout*npts+1,ncout) = onenum;
          out(1:npts,ncout+1) = omega1;
          fone = (npts+1)*onerows;
          ftwo = (npts+1)*tworows;
          fout = (npts+1)*nrout;
          pone = 1:onerows:fone;
          ptwo = 1:tworows:ftwo;
          pout = 1:nrout:fout;
          ponem1 = pone(2:npts+1) - 1;
          ptwom1 = ptwo(2:npts+1) - 1;
          poutm1 = pout(2:npts+1) - 1;
          for i=1:npts
            tmp1 = mat1(pone(i):ponem1(i),1:onecols);
            tmp2 = mat2(ptwo(i):ptwom1(i),1:twocols);
            out(pout(i):poutm1(i),1:ncout) = ...
               genlft(tmp1,tmp2,dim1,dim2);
          end
        else
          error('inconsistent varying data')
          return
        end
      else
%       VARYING & CONSTANT
        [nr1,nc1] = size(mat1);
        omega = mat1(1:onenum,nc1);
        npts = onenum;
        nrout = onerows + tworows - dim1 - dim2;
        ncout = onecols + twocols - dim1 - dim2;
        out = zeros(nrout*npts+1,ncout+1);
        out(nrout*npts+1,ncout+1) = inf;
        out(nrout*npts+1,ncout) = onenum;
        out(1:npts,ncout+1) = omega;
        fone = (npts+1)*onerows;
        fout = (npts+1)*nrout;
        pone = 1:onerows:fone;
        pout = 1:nrout:fout;
        ponem1 = pone(2:npts+1) - 1;
        poutm1 = pout(2:npts+1) - 1;
        for i=1:npts
          tmp1 = mat1(pone(i):ponem1(i),1:onecols);
          out(pout(i):poutm1(i),1:ncout) = ...
             genlft(tmp1,mat2,dim1,dim2);
        end
      end
    elseif onetype == 'cons'
      if twotype == 'vary'
%       CONSTANT*VARYING
        [nr2,nc2] = size(mat2);
        omega = mat2(1:twonum,nc2);
        npts = twonum;
        nrout = onerows + tworows - dim1 - dim2;
        ncout = onecols + twocols - dim1 - dim2;
        out = zeros(nrout*npts+1,ncout+1);
        out(nrout*npts+1,ncout+1) = inf;
        out(nrout*npts+1,ncout) = twonum;
        out(1:npts,ncout+1) = omega;
        ftwo = (npts+1)*tworows;
        fout = (npts+1)*nrout;
        ptwo = 1:tworows:ftwo;
        pout = 1:nrout:fout;
        ptwom1 = ptwo(2:npts+1) - 1;
        poutm1 = pout(2:npts+1) - 1;
        for i=1:npts
          tmp2 = mat2(ptwo(i):ptwom1(i),1:twocols);
          out(pout(i):poutm1(i),1:ncout) = ...
             genlft(mat1,tmp2,dim1,dim2);
        end
      elseif twotype == 'cons'
%       CONSTANT & CONSTANT
        out = genlft(mat1,mat2,dim1,dim2);
      else
%       CONSTANT*SYSTEM
        out = redstar(mat1,mat2,dim1,dim2);
      end
    else
      if twotype == 'cons'
%       SYSTEM*CONSTANT
        out = redstar(mat1,mat2,dim1,dim2);
      else
%       SYSTEM*SYSTEM
        out = redstar(mat1,mat2,dim1,dim2);
      end
    end
  end
%
%