function indices = utAsgnCheck(sys,indices,sizes,DelFlag)
% Checks and format indices for SUBSASGN
%
%   IND = UTASGNCHECK(SYS,IND,SIZES,DELFLAG) performs the following tasks:
%     * Check compatibility of SUBSASGN indices IND and dimensions 
%       SIZES of the LHS for deletion assignments (RHS=[], DELFLAG=1)
%     * Replace all name references in IND(1:2) by integer-valued 
%       subscripts using the I/O channel and group names of the LHS.  

%   Author(s):  P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:52 $

% Format subscripts and resolve name-based subscripts
indices = formatsubs(indices,sizes);

% Turn name references into regular indices (first 2D only)
for j=1:2,
   indices{j} = utNameRef(sys,indices{j},j); 
end

% Make sure any logical indices are at least as big as the array dimension
% Only check the first ND, in case we are growing an array..
nd = length(sizes); 
nind = length(indices);
logix = find(cellfun('islogical',indices(1:min(nind,nd))));
badix = cellfun('length',indices(logix))<sizes(logix);
if any(badix)
   error(sprintf('Logical subscript #%i has wrong length.', logix(badix(1))));
end

% Handle case SYS(i1,...,ik) = [].
% Note: All error checking for  SYS(i1,...,ik) = non-empty RHS 
% is deferred to the built-in code for ND array assignments
if DelFlag,
   % Get positions of non-colon indexes
   iscolon = strcmp(indices,':'); 
   nci = find(~iscolon);
   if nind>nd,
      % Too many indices
      error('In empty assignment, number of indexes must match number of dimensions.')
   elseif length(nci)>1,
      % All indices but one should be colons
      error('Empty assignments SYS(i1,..,ik)=[] can have only one non-colon index.')
   elseif length(nci)==1,
      ncindex = indices{nci};
      if nind<nd && nci==nind,
         % Absolute array indexing
         snci = prod(sizes(nci:end));
      else
         snci = sizes(nci);
      end
      if (islogical(ncindex) && length(ncindex)>snci) || ...
         (~islogical(ncindex) && (any(ncindex<=0) || any(ncindex>snci))),
          error('Index out of range in empty assignment.')
      end
   end
   % Pad INDICES with colons if NIND<NLD and last index is a colon
   if nind<nd && iscolon(nind),
      indices(nind+1:nd) = {':'};
   end
end
