% function out = sbs(mat1,mat2,mat3,...,matN)
%
%   Place SYSTEM/VARYING/CONSTANT matrices next to
%   one another. Currently limited to 9 input matrices.
%   All of the matrices must have the same number of
%   rows (outputs).
%
%   out = [mat1  mat2  mat3  ...  matN]
%
%   See also: ABV, MADD, DAUG, MMULT, and MSCL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = sbs(mat1,mat2,mat3,mat4,mat5,mat6,mat7,mat8,mat9)
 if nargin < 2
   disp('usage: out = sbs(mat1,mat2,mat3,...,matN)')
   return
 elseif nargin == 2
   le = mat1;
   ri = mat2;
   if isempty(le)
     out = ri;
   elseif isempty(ri)
     out = le;
   else
     [ltype,lrows,lcols,lnum] = minfo(le);
     [rtype,rrows,rcols,rnum] = minfo(ri);
     if (ltype == 'vary' & rtype == 'syst') | ...
         (ltype == 'syst' & rtype == 'vary')
       error('side-by-side of SYSTEM and VARYING not allowed')
       return
     elseif lrows ~= rrows
       error('incompatible row (input) dimensions')
       return
     end
     if ltype == 'vary'
       if rtype == 'vary'
%	 [VARYING VARYING]
         code = indvcmp(le,ri);
         if code == 1;
           [vdl,rpl,indvl] = vunpck(le);
           [vdr,rpr,indvr] = vunpck(ri);
	   out = zeros(lrows*lnum+1,lcols+rcols+1);
	   out(lrows*lnum+1,lcols+rcols+1) = inf;
	   out(lrows*lnum+1,lcols+rcols) = lnum;
	   out(1:lnum,lcols+rcols+1) = indvl;
	   out(1:lrows*lnum,1:lcols+rcols) = [vdl vdr];
         else
           error('varying data is inconsistent')
           return
         end
       else
%	 [VARYING CONSTANT]
         [vdl,rpl,indvl] = vunpck(le);
	 out = zeros(lrows*lnum+1,lcols+rcols+1);
	 out(lrows*lnum+1,lcols+rcols+1) = inf;
	 out(lrows*lnum+1,lcols+rcols) = lnum;
	 out(1:lnum,lcols+rcols+1) = indvl;
	 out(1:lrows*lnum,1:lcols+rcols) = [vdl kron(ones(lnum,1),ri)];
       end
     elseif ltype == 'cons'
       if rtype == 'vary'
%	 [CONSTANT VARYING]
         [vdr,rpr,indvr] = vunpck(ri);
	 out = zeros(lrows*rnum+1,lcols+rcols+1);
	 out(lrows*rnum+1,lcols+rcols+1) = inf;
	 out(lrows*rnum+1,lcols+rcols) = rnum;
	 out(1:rnum,lcols+rcols+1) = indvr;
	 out(1:lrows*rnum,1:lcols+rcols) = [kron(ones(rnum,1),le) vdr];
       elseif rtype == 'cons'
         out = [le ri];
       else
         [a,b,c,d] = unpck(ri);
         bb = [zeros(rnum,lcols) b];
         dd = [le d];
         out = pck(a,bb,c,dd);
       end
     else
       if rtype == 'cons'
         [a,b,c,d] = unpck(le);
         bb = [b zeros(lnum,rcols)];
         dd = [d ri];
         out = pck(a,bb,c,dd);
       else
         [ale,ble,cle,ddle] = unpck(le);
         [ari,bri,cri,ddri] = unpck(ri);
         a = [ale zeros(lnum,rnum) ; zeros(rnum,lnum) ari];
         b = [ble zeros(lnum,rcols) ; zeros(rnum,lcols) bri];
         c = [cle cri];
         d = [ddle ddri];
         out = pck(a,b,c,d);
       end
     end
   end
 else
%   recursive call for multiple input arguments
   exp = ['out=sbs(sbs('];
   for i=1:nargin-2
     exp=[exp 'mat' int2str(i) ','];
   end
   exp = [exp 'mat' int2str(nargin-1) '),mat' int2str(nargin) ');'];
   eval(exp);
 end
%
%