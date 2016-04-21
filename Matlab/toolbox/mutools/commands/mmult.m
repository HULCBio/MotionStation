% function out = mmult(mat1,mat2,mat3,...,matN)
%
%   Multiplies SYSTEM/VARYING/CONSTANT matrices, currently
%   limited to 9 input arguments
%
%   out = mat1*mat2*mat3* *** *matN
%
%   See also: *, ABV, MADD, MSCL, and MSUB.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = mmult(mat1,mat2,mat3,mat4,mat5,mat6,mat7,mat8,mat9)
  if nargin <= 1
    disp('usage: out = mmult(mat1,mat2,mat3,...,matN)')
    return
  elseif nargin == 2
    [m1type,m1rows,m1cols,m1num] = minfo(mat1);
    [m2type,m2rows,m2cols,m2num] = minfo(mat2);
    if (m1type == 'syst' & m2type == 'vary') | ...
         (m1type == 'vary' & m2type == 'syst')
      error('MMULT of SYSTEM and VARYING not allowed')
      return
    elseif m1type == 'empt' | m2type == 'empt'
      out = [];
      return
    elseif m1cols ~= m2rows
      error('MMULT incompatible inner dimensions')
      return
    end
    outrows = m1rows;
    outcols = m2cols;
    if m1type == 'vary'
      if m2type == 'vary'
%       both varying
        code = indvcmp(mat1,mat2);
        if code == 1
          [vd1,rp1,indv1] = vunpck(mat1);
          [vd2,rp2,indv2] = vunpck(mat2);
          out = zeros(m1num*m1rows+1,m2cols+1);
	  out(m1num*m1rows+1,m2cols+1) = inf;
	  out(m1num*m1rows+1,m2cols) = m1num;
	  out(1:m1num,m2cols+1) = indv1;
          for i=1:m1num
             out(rp1(i):rp1(i)+m1rows-1,1:m2cols) = ...
                mat1(rp1(i):rp1(i)+m1rows-1,1:m1cols)...
                *mat2(rp2(i):rp2(i)+m2rows-1,1:m2cols);
          end
        else
          error('inconsistent varying data')
	  return
        end
      else
%       varying*constant
        [vd1,rp1,indv1] = vunpck(mat1);
        out = zeros(m1num*m1rows+1,m2cols+1);
	out(m1num*m1rows+1,m2cols+1) = inf;
	out(m1num*m1rows+1,m2cols) = m1num;
	out(1:m1num,m2cols+1) = indv1;
        out(1:m1num*m1rows,1:m2cols) = vd1*mat2;
      end
    elseif m1type == 'cons'
      if m2type == 'vary'
%       constant*varying
        [vd2,rp2,indv2] = vunpck(mat2);
        out = zeros(m2num*m1rows+1,m2cols+1);
	out(m2num*m1rows+1,m2cols+1) = inf;
	out(m2num*m1rows+1,m2cols) = m2num;
	out(1:m2num,m2cols+1) = indv2;
        tmp = mat1 * reshape(vd2,m2rows,m2num*m2cols);
        out(1:m2num*m1rows,1:m2cols) = reshape(tmp,m1rows*m2num,m2cols);
      elseif m2type == 'cons'
%       constant*constant
        out = mat1 * mat2;
      else
%       constant*system
        [a,b,c,d] = unpck(mat2);
        out = pck(a,b,mat1*c,mat1*d);
      end
    else
      if m2type == 'cons'
%       system*constant
        [a,b,c,d] = unpck(mat1);
        out = pck(a,b*mat2,c,d*mat2);
      else
%       system*system
        [a1,b1,c1,d1] = unpck(mat1);
        [a2,b2,c2,d2] = unpck(mat2);
        zer = zeros(m2num,m1num);
        a = [a1 b1*c2 ; zer a2];
        b = [b1*d2 ; b2];
        c = [c1 d1*c2];
        d = d1*d2;
        out = pck(a,b,c,d);
      end
    end
  else
    exp = ['out=mmult(mmult('];
    for i=1:nargin-2
      exp=[exp 'mat' int2str(i) ','];
    end
    exp = [exp 'mat' int2str(nargin-1) '),mat' int2str(nargin) ');'];
    eval(exp);
  end
%
%