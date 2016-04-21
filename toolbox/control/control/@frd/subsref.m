function result = subsref(sys,Struct)
%SUBSREF  Subscripted reference for LTI objects
%
%   The following reference operations can be applied to any 
%   LTI model SYS: 
%      SYS(Outputs,Inputs)   select subset of I/O channels
%      SYS.Fieldname         equivalent to GET(SYS,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.Frequency(1).
%
%   For LTI arrays, indexed referencing takes the form
%      SYS(Outputs,Inputs,j1,...,jk)
%   where k is the number of extra dimensions (in addition
%   to the generic input and output dimensions).  Use 
%      SYS(:,:,j1,...,jk)
%   to access the (j1,...,jk) model in the LTI array.
%
%   See also GET, FRDATA, SUBSASGN, LTIMODELS.

%   Author(s): P. Gahinet, S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/10 06:16:30 $

% Effect on LTI properties: all inherited

ni = nargin;
if ni==1,
   result = sys;   return
end
StructL = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
case '.'
   % The first subreference is of the form sys.fieldname
   % The output is a piece of one of the system properties
   try
      if StructL==1,
         result = get(sys,Struct(1).subs);
      else
         result = subsref(get(sys,Struct(1).subs),Struct(2:end));
      end
   catch
      rethrow(lasterror)
   end
   
case '()'
   % The first subreference is of the form sys(indices)
   try
      if StructL==1,
         result = indexref(sys,Struct(1).subs);
      else
         result = subsref(indexref(sys,Struct(1).subs),Struct(2:end));
      end
   catch
      rethrow(lasterror)
   end

case '{}'
   error('Cell contents reference from a non-cell array object.')

otherwise
   error(sprintf('Unknown reference type: %s',Struct(1).type))
end


% Subfunction INDEXREF: Evaluates sys(indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexref(sys,indices)

nind = length(indices);


% look for frequency access flag in indices
try
   [indices,freqIndices] = getfreqindex(sys, indices);
   nind = length(indices);
catch
   rethrow(lasterror);
end

% Handle absolute indexing
sizes = size(sys.ResponseData);

sizes(3:min(3,end)) = [];  % ignore frequency dimension
if nind==1,
   if length(sizes)>2 | min(sizes)>1,
      error('Use multiple indexing for MIMO models or LTI arrays, as in SYS(i,j).');
   elseif sizes(1)==1,  % 2D, single output
      indices = [{':'} indices];
   else                 % 2D, single input
      indices = [indices {':'}];
   end
elseif length(sizes)==2 & isequal(indices,{':' ':' 1}),
   % Quick exit for SYS(:,:,1) to avoid penalizing single-model case
   return
end

% Check and format indices
indices = refchk(indices,sizes,sys.lti);
freqIndices = freqrefchk(freqIndices,length(sys.Frequency));

% Extract desired subsystem
sys.ResponseData = sys.ResponseData(indices{1:2},freqIndices,indices{3:end});
sys.Frequency = sys.Frequency(freqIndices,:);
sys.lti = sys.lti(indices{:});


% Subfunction FREQREFCHK: Check frequency indices for subsref
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function freqIndices = freqrefchk(freqIndices, freqSize);

if islogical(freqIndices)           % bound the size of logicals
   if length(freqIndices)~=freqSize
      error('Logical frequency index has wrong length.');
   end
elseif isnumeric(freqIndices)
   if ~all(diff(freqIndices)>0) | freqIndices ~= floor(freqIndices)
      error('Frequency indices must be strictly increasing integers.');
   elseif ~isempty(freqIndices) & ...
         (freqIndices(1)<1 | freqIndices(end)>freqSize)
      error('Frequency index is out of range.');
   end
elseif ~ischar(freqIndices) | ~strcmp(freqIndices,':')
   error('Frequency index cannot be processed.');
end
