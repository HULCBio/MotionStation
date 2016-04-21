% function [sysout,v] = strans(sys)
%
%   STRANS puts the A matrix in bidiagonal form
%   with the complex conjugate roots in two by two form.
%   SYSOUT contains the transformed SYSTEM matrix and
%   V is the transformation matrix.
%
%   See also: EIG, MMULT, REORDSYS, STATECC, SCLIN,
%             SCLOUT, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [sysout,vzi] = strans(sys);
 if nargin ~= 1
   disp('usage: [sysout,v] = strans(sys)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 if mtype == 'syst'
   if mnum == 0
     disp('input matrix has no states')
   else
    [a,b,c,d] = unpck(sys);
    [v,dia] = eig(a);
%  reorder by increasing magnitude
    [dia,isort] = sort(diag(dia));
    v = v(:,isort);
    comp = imag(dia);
    i = find(comp);
    nelem = length(i);
    if ceil(nelem/2) ~= floor(nelem/2)
      error(' there are an odd number of complex roots')
      return
    end
    z = sqrt(1/2)*[1 sqrt(-1); sqrt(-1) 1];
    old = 0;
    [nr,nc] = size(a);
    mat = eye(nr,nc);
    mat1 = mat;
%    construct the transformation matrix
    for ix = 1:nelem
      if ix ~= old
        mat(i(ix),i(ix)) = z(1,1);
        mat(i(ix),i(ix)+1) = z(1,2);
        mat(i(ix)+1,i(ix)) = z(2,1);
        mat(i(ix)+1,i(ix)+1) = z(2,2);
        mat1(i(ix),i(ix)) = 1;
        mat1(i(ix),i(ix)+1) = 1;
        mat1(i(ix)+1,i(ix)) = 1;
        mat1(i(ix)+1,i(ix)+1) = 1;
        old = ix+1;
      else
        old = 0;
      end
    end

    vzi = sign(real(v/mat)).*abs(v/mat);
    vzii = sign(real(mat/v)).*abs(mat/v);
    anew = vzii*a*vzi;
    bnew = vzii*b;
    cnew = c*vzi;
%   zeros out some round off error
    anew = anew.*mat1;
    sysout = pck(anew,bnew,cnew,d);
   end
 else
   error('input matrix is not a SYSTEM matrix')
   return
 end
%
%
