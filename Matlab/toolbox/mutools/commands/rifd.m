% function rifd(vec)
%
%   Displays the real, imaginary, frequency (magnitude) and
%   damping ratios (-real/magnitude) of the input vector VEC.
%
%   See also: EIG, SPOLES and SZEROS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function rifd(vec)
 if nargin ~= 1
   disp('usage: rifd(vec)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(vec);
 if mtype == 'cons'
   if mrows ~= 1 & mcols ~= 1
     error('input vector should be a ROW or COLUMN vector')
     return
   else
     eigval = sort(vec);
     om = abs(eigval);
     damp = -real(eigval)./om;
     re = real(eigval);
     ie = imag(eigval);
     disp([' '])
     disp(['      real       imaginary     frequency      damping'])
     disp([' '])
     for i=1:length(vec)
	mprintf([ re(i) ie(i) om(i) damp(i)],'  %.4e ');
     end %for
   end
 else
   error('input vector is not a CONSTANT matrix')
   return
 end
%
%