function indices = utRefCheck(sys,indices,sizes)
% Check and format indices for SUBSREF
%
%   IND = UTREFCHECK(SYS,IND,SIZES) checks the SUBSREF indices IND
%   against the model SIZES and the I/O names/groups of SYS,
%   and turns all name-based references in IND into integer-valued 
%   subscripts.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:04 $

% Format subscripts and resolve name-based subscripts
indices = formatsubs(indices,sizes);

% Turn name references into regular indices (first 2 dimensions only)
for j=1:2, 
   indices{j} = utNameRef(sys,indices{j},j); 
end

% Make SIZES the same length as INDICES
%  * if NIND<ND (absolute reference into LTI array), fold the dimensions 
%    NIND through ND into a single dimension
%  * if NIND>ND, pad SIZES with unit sizes.
nd = length(sizes); 
nind = length(indices);
sizes = [sizes(1:min(nind-1,nd)) prod(sizes(nind:nd)) ones(1,nind-nd)];

% Check compatibility of indices with sizes
% RE: at this point, LENGTH(SIZES) = LENGTH(INDICES)
nci = find(~strcmp(indices,':'));  % locate non-colon indices
for j=nci,
   indj = indices{j};
   if islogical(indj);
      if length(indj)~=sizes(j)
         error(sprintf('Logical subscript #%d has wrong length.',j));
      end
   elseif isnumeric(indj)
      if any(indj<1 | indj>sizes(j))
         error(sprintf('Subscript #%d is out of range.',j));
      end
   else
      error(sprintf('Subscript #%d cannot be processed.',j))
   end
   indices{j} = reshape(indj,[1 length(indj)]);
end

