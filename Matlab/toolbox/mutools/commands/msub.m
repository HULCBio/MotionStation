% function out = msub(mat1,mat2,...,matN)
%
%   Subtract SYSTEM/VARYING/CONSTANT matrices, currently limited
%   to 9 input arguments.
%
%   out = mat1 - mat2 - mat3 - ... - matN
%
%   See also: ABV, MADD, DAUG, MMULT, and MSCL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = msub(mat1,mat2,mat3,mat4,mat5,mat6,mat7,mat8,mat9)
  if nargin <= 1
    disp('usage: out = msub(mat1,mat2,...,matN)')
    return
  elseif nargin == 2
    [onetype,onerows,onecols,onenum] = minfo(mat1);
    [twotype,tworows,twocols,twonum] = minfo(mat2);
    if onetype == 'empt' & twotype == 'empt'
      out = [];
      return
    end
    if (onetype == 'syst' & twotype == 'vary') | ...
          (onetype == 'vary' & twotype == 'syst')
       error('subtraction of SYSTEM and VARYING not allowed')
       return
    elseif onerows ~= tworows | onecols ~= twocols
      error('incompatible dimensions in MSUB')
      return
    end
    if onetype == 'vary'
      if twotype == 'vary'
%       both varying
        code = indvcmp(mat1,mat2);
        if code == 1
          [nr,nc] = size(mat1);
          [vd1,rp1,indv1] = vunpck(mat1);
          [vd2,rp2,indv2] = vunpck(mat2);
          out = vpck(vd1-vd2,indv1);
        else
          error(['inconsistent varying data'])
          return
        end
      else
%       varying-constant
        [vd1,rp1,indv1] = vunpck(mat1);
        out = vpck(vd1-kron(ones(onenum,1),mat2),indv1);
      end
    elseif onetype == 'cons'
      if twotype == 'vary'
%       constant-varying
        [vd2,rp2,indv2] = vunpck(mat2);
        out = vpck(kron(ones(twonum,1),mat1)-vd2,indv2);
      elseif twotype == 'cons'
%       constant-constant
        out = mat1 - mat2;
      else
%       constant-system
        [a,b,c,d] = unpck(mat2);
        out = pck(a,b,-c,mat1-d);
      end
    else
      if twotype == 'cons'
%       system-constant
        [a,b,c,d] = unpck(mat1);
        out = pck(a,b,c,d-mat2);
      else
%       system-system
        [a1,b1,c1,d1] = unpck(mat1);
        [a2,b2,c2,d2] = unpck(mat2);
        zer = zeros(twonum,onenum);
        a = [a1 zer' ; zer a2];
        b = [b1 ; -b2];
        c = [c1 c2];
        d = d1-d2;
        out = pck(a,b,c,d);
      end
    end
  else
%   recursive call for multiple input arguments
     exp = ['out=msub(msub('];
     for i=1:nargin-2
       exp=[exp 'mat' int2str(i) ','];
     end
     exp = [exp 'mat' int2str(nargin-1) '),mat' int2str(nargin) ');'];
     eval(exp);
  end
%
%