function result = subsref(sys,Struct)
%SUBSREF  Subscripted reference for LTI objects.
%
%   The following reference operations can be applied to any 
%   LTI model SYS: 
%      SYS(Outputs,Inputs)   select subset of I/O channels
%      SYS.Fieldname         equivalent to GET(SYS,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%   For LTI arrays, indexed referencing takes the form
%      SYS(Outputs,Inputs,j1,...,jk)
%   where k is the number of array dimensions (in addition
%   to the generic input and output dimensions).  Use 
%      SYS(:,:,j1,...,jk)
%   to access the (j1,...,jk) model in the LTI array.
%
%   See also GET, TFDATA, SUBSASGN, LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/10 06:11:48 $

% Effect on LTI properties: all inherited

ni = nargin;
if ni==1,
   result = sys;
   return
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
   error(sprintf('Unknown reference type: %s',Struct(1).type));
end


%%%%%% local function %%%%%%%%

function sys = indexref(sys,indices)
%INDEXREF  Evaluates sys(indices)

% Handle absolute indexing
sizes = size(sys.k);
nind = length(indices);
if nind==1,
   if length(sizes)>2 | min(sizes)>1,
      error('Use multiple indexing for MIMO systems or LTI arrays, as in SYS(i,j).');
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

% Extract desired subsystem
sys.z = sys.z(indices{:});
sys.p = sys.p(indices{:});
sys.k = sys.k(indices{:});
sys.lti = sys.lti(indices{:});