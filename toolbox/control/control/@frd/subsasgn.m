function sys = subsasgn(sys,Struct,rhs)
%SUBSASGN  Subscripted assignment for LTI objects.
%
%   The following assignment operations can be applied to any 
%   LTI model SYS: 
%     SYS(Outputs,Inputs)=RHS  reassigns a subset of the I/O channels
%     SYS.Fieldname=RHS        equivalent to SET(SYS,'Fieldname',RHS)
%   The left-hand-side expressions can be themselves followed by any 
%   valid subscripted reference, as in SYS(1,[2 3]).inputname='u' or
%   SYS.ResponseData(1)=[ ... ].
%
%   For arrays of LTI models, indexed assignments take the form
%      SYS(Outputs,Inputs,j1,...,jk) = RHS
%   where k is the number of array dimensions (in addition to the
%   input and output dimensions).
%
%   See also SET, SUBSREF, LTIMODELS.

%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 06:16:32 $


if nargin==1,
   return
elseif ~isa(sys,'lti') & ~isempty(sys)
   sys = builtin('subsasgn',sys,Struct,rhs);
   return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
case '.'
   % Assignment of the form sys.fieldname(...)=rhs
   FieldName = Struct(1).subs;
   try
      if StructL==1,
         FieldValue = rhs;
      else
         FieldValue = subsasgn(get(sys,FieldName),Struct(2:end),rhs);
      end
      set(sys,FieldName,FieldValue)
   catch
      rethrow(lasterror)
   end
   
case '()'
   % Assignment of the form sys(indices)...=rhs
   try
      if StructL==1,
         sys = indexasgn(sys,Struct(1).subs,rhs);
      else
         % First reassign tmp = sys(indices)
         tmp = subsasgn(subsref(sys,Struct(1)),Struct(2:end),rhs);
         % Then set sys(indices) to tmp
         sys = indexasgn(sys,Struct(1).subs,tmp);
      end
   catch
      rethrow(lasterror)
   end
   
case '{}'
   error('Cell contents reference from a non-cell array object.')
   
otherwise
   error(sprintf('Unknown type: %s', Struct(1).type))
end



% Subfunction INDEXASGN: Reassigns sys(indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexasgn(sys,indices,rhs)

% Handle case when SYS is created by subsasgn statement
if isa(sys,'double'),
   % Initialize to empty FRD
   sys = frd;
   emptySys = 1;
else
   emptySys = 0;
end
DelFlag = isequal(rhs,[]);  % flags deletions SYS(INDICES)=[]

% look for frequency access flag in indices
try
   [indices,freqIndices] = getfreqindex(sys, indices);
catch
   rethrow(lasterror);
end

% system dimensions
sizeSys = size(sys.ResponseData);
sizeSys(3:min(3,end)) = [];  % ignore frequency dimension of sys

% Check and format indices
indices = asgnchk(indices,sizeSys,DelFlag,sys.lti);
freqIndices = freqasgnchk(freqIndices,length(sys.Frequency));

% add frequency dimension
indices = [ indices(1:2) {freqIndices} indices(3:end) ];
sizeSys = [ sizeSys(1:2) size(sys.ResponseData,3) sizeSys(3:end) ];

% Handle case SYS(i1,...,ik) = []
if DelFlag,
   iscolon = strcmp(indices,':');
   nci = find(~iscolon);
   if length(nci)>1,
      % All indices but one should be colons
      error('Empty assignments SYS(i1,..,ik)=[] can have only one non-colon index.')
   elseif isempty(nci) % deleting everything
      sys.ResponseData = zeros([sizeSys(1:2),0,sizeSys(4:end)]);
      sys.Frequency = zeros(0,1);
   else
      % Delete parts of SYS
      sys.ResponseData(indices{:}) = [];
      if nci==3 % deleting all responses at certain frequencies - remove freqs
         sys.Frequency(freqIndices,:) =[];
      end
   end
   sys.lti = ltiasgn(sys.lti,indices,[]);
   return
   
elseif isa(rhs,'double'),  % RHS is a ND array
      
   if isnumeric(freqIndices) & ~all(diff(round(freqIndices))>0)
      error('Frequency indices must be in increasing order.');
   elseif isempty(sys.Frequency) & size(rhs,3)
      %error('Unable to assign array into empty FRD model.');
      sizeRHS = size(rhs);
      rhs = zeros([sizeRHS(1:2) 0 sizeRHS(4:end)]);
   end
   
   % Expand to all indexed frequencies, allow ND scalar assignment.
   sizeRHS = size(rhs);
   zeroRHS = all(~rhs(:));
   
   % Update ResponseData. Rely on ND assignment code to detect errors
   sys.ResponseData(indices{:}) = rhs;
   sflags = [isstatic(sys) , 1];  % no sample time conflict in this case
   rlti = lti(1,1);   % same as scalar assignment from LTI viewpoint
   
elseif isa(rhs,'frd')
   
   if emptySys
      sys.Frequency = rhs.Frequency;
      sys.ResponseData(indices{:}) = rhs.ResponseData;
      zeroRHS = all(rhs.ResponseData(:) == 0);
      sys.Units = rhs.Units;
      rlti = rhs.lti;
      sizeRHS = size(rhs);
      sflags = [isstatic(sys) , isstatic(rhs)];
   else
      
      % check units-dependent frequency consistency
      freqcheck(sys.Frequency(freqIndices),sys.Units,rhs.Frequency, rhs.Units);
      
      if isnumeric(freqIndices) & ~all(diff(round(freqIndices))>0)
         error('Frequency indices must be in increasing order.');
      end
      
      % Update ResponseData. Rely on ND assignment code to detect errors
      zeroRHS = all(rhs.ResponseData == 0);
      sys.ResponseData(indices{:}) = rhs.ResponseData;
      sizeRHS = size(rhs);
      sizeRHS(3:min(3,end)) = [];  % ignore frequency dimension
      sflags = [isstatic(sys) , isstatic(rhs)];
      rlti = rhs.lti;
   end
   
else % other LTI
   if isnumeric(freqIndices) & ~all(diff(round(freqIndices))>0)
      error('Frequency indices must be in increasing order.');
   end
   
   rhs = frd(rhs,sys.Frequency(freqIndices),'Units',sys.Units); % convert to FRD, keeping units of sys
   
   % Update ResponseData. Rely on ND assignment code to detect errors
   sys.ResponseData(indices{:}) = rhs.ResponseData;
   zeroRHS = all(rhs.ResponseData(:) == 0);
   sizeRHS = size(rhs.ResponseData);
   sizeRHS(3:min(3,end)) = [];  % ignore frequency dimension
   sflags = [isstatic(sys) , isstatic(rhs)];
   rlti = rhs.lti;
   
end


% Prohibit sys(1,2,1:10) = 1x10 FRD (should be 1x1x10 to preserve I/O dims)
if isa(rhs,'lti') & ~all(sizeRHS==1),
   % Get first two dimensions LSIZES of the assigned portion of the LHS
   lsizes = size(sys.ResponseData);  % use current sizes in case LHS created by assignment
   for j=find(~strcmp(indices(1:2),':')),  % non-colon indices
      if islogical(indices{j}),
         lsizes(j) = length(find(indices{j}));
      else
         lsizes(j) = length(indices{j});
      end
   end
   if ~isequal(sizeRHS(1:2),lsizes(1:2)),
      error('I/O dimension mismatch in LTI assignment.')
   end
end

% LTI property management:
% (1) Adjust sample time of static gains to avoid unwarranted clashes
%     RE: static gains are regarded as sample-time free
if any(sflags),
   [sys.lti,rlti] = sgcheck(sys.lti,rlti,sflags);
end

% (2) Update LTI properties of LHS
sizeSys(3:end) = [];  % remove frequency dimension of sys
newSize = size(sys.ResponseData);
newSize(3:min(3,end)) = [];  % ignore frequency dimension
sys.lti = ltiasgn(sys.lti,indices,rlti,sizeSys,newSize,sizeRHS,zeroRHS);


% Subfunction FREQASGNCHK: Check frequency indices for subsref
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function freqIndices = freqasgnchk(freqIndices, freqSize);

if islogical(freqIndices)           % bound the size of logicals
   if length(freqIndices) ~= freqSize
      error('Logical frequency index has wrong length.');
   end
   freqIndices = find(freqIndices);
elseif isnumeric(freqIndices)
   if min(freqIndices)<1 | max(freqIndices)>freqSize
      error('Frequency index is out of range.');
   end
elseif ~ischar(freqIndices) | ~strcmp(freqIndices,':')
   error('Frequency index cannot be processed.');
end

