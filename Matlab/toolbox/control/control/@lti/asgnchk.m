function indices = asgnchk(indices,sizes,DelFlag,L)
%ASGNCHK  Check and format indices for SUBSASGN
%
%   IND = ASGNCHK(IND,SIZES,DELFLAG,L) performs the following tasks:
%     * Check compatibility of SUBSASGN indices IND and dimensions 
%       SIZES of the LHS for deletion assignments (RHS=[], DELFLAG=1)
%     * Replace all name references in IND(1:2) by integer-valued 
%       subscripts using the I/O channel and group names in the
%       LTI parent L of the LHS.  
%
%   See also SUBSASGN.

%   Author(s):  P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:52:15 $


% Consistency checks
nind = length(indices);
nld = length(sizes); 
if nind==1,
   if length(sizes)>2 | min(sizes)>1,
      error('Use multiple indexing for MIMO models or LTI arrays, as in SYS(i,j).');
   elseif sizes(1)==1,  % 2D, single output
      indices = [{':'} indices];
   else                 % 2D, single input
      indices = [indices {':'}];
   end
   nind = length(indices);
elseif nld>2 & nind==2,
   % SYS(i,j) = RHS for LTI arrays (no indices into the array). Interpret as 
   % reassigning an I/O pair across the entire array (see REFCHK for justification)
   indices = [indices repmat({':'},1,nld-2)];
   nind = nld;
end

% Turn name references into regular indices (first 2D only)
for j=1:2,
   indices{j} = nameref(indices{j},L,j); 
end

% Make sure any logical indices are at least as big as the array dimension
% Only check the first nld, in case we are growing an array..
logix = find(cellfun('islogical',indices(1:min(end,nld))));
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
   if nind>nld,
      % Too many indices
      error('In empty assignment, number of indexes must match number of dimensions.')
   elseif length(nci)>1,
      % All indices but one should be colons
      error('Empty assignments SYS(i1,..,ik)=[] can have only one non-colon index.')
   elseif length(nci)==1,
      ncindex = indices{nci};
      if nind<nld & nci==nind,
         % Absolute array indexing
         snci = prod(sizes(nci:end));
      else
         snci = sizes(nci);
      end
      if (islogical(ncindex) & length(ncindex)>snci) | ...
         (~islogical(ncindex) & (ncindex<=0 | ncindex>snci)),
          error('Index out of range in empty assignment.')
      end
   end
   % Pad INDICES with colons if NIND<NLD and last index is a colon
   if nind<nld & iscolon(nind),
      indices(nind+1:nld) = {':'};
   end
end
