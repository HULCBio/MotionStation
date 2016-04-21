%  m = mdiag(a1,a2,...)
%
%  Forms the block-diagonal matrix
%            [ a1  0  .. 0 ]
%            [ 0  a2     : ]
%       M =  [ :         0 ]
%            [ 0  ..  0 an ]
%  The number of input arguments is limited to 10.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function m=mdiag(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)

if nargin > 10, error('The number of input arguments is limited to 10'); end

m=a1;
for k=2:nargin
   [rm,cm]=size(m);
   eval(['[ra,ca]=size(a' int2str(k) ');']);
   eval(['m=[m zeros(rm,ca);zeros(ra,cm) a' int2str(k) '];']);
end
