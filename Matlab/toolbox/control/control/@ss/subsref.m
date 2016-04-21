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
%   $Revision: 1.21 $  $Date: 2002/04/10 06:00:11 $

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



% Subfunction INDEXREF: Evaluates sys(indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexref(sys,indices)

sizes = size(sys.d);
nd = length(sizes);

% Check indices
nind = length(indices);
if nind==1,
   if nd>2 | min(sizes)>1,
      error('Use multiple indexing for MIMO models or LTI arrays, as in SYS(i,j).');
   elseif sizes(1)==1,  % 2D, single output
      indices = [{':'} indices];
   else                 % 2D, single input
      indices = [indices {':'}];
   end
elseif nd==2 & isequal(indices,{':' ':' 1}),
   % Quick exit for SYS(:,:,1) to optimize multi-model loops in single-model case
   return
end

% Check and format indices
indices = refchk(indices,sizes,sys.lti);

% Select desired models in A,B,C,E data
if length(indices)>2 & ...
      (length(indices)<nd | ~all(strcmp(indices(3:end),':'))),
   ArrayIndices = indices(3:end);
   if length(ArrayIndices)==1 & length(sizes)==2,
      % For a single model, sys.a([1 1 1]) will produce a 1x3 array 
      % instead of 3x1 array expected from sys(:,:,[1 1 1])
      ArrayIndices = [ArrayIndices {1}];
   end
   sys.a = sys.a(ArrayIndices{:});
   sys.b = sys.b(ArrayIndices{:});
   sys.c = sys.c(ArrayIndices{:});
   sys.e = ematchk(sys.e(ArrayIndices{:}));
   nx = size(sys,'order');
   sys.StateName = sys.StateName(1:max(nx(:)),1);
end

% Select desired I/Os in B,C data
if ~all(strcmp(indices(1:2),':')),
   for k=1:prod(size(sys.a)),
      sys.b{k} = sys.b{k}(:,indices{2});
      sys.c{k} = sys.c{k}(indices{1},:);
   end
end

% Extract desired portion of D array and LTI data
sys.d = sys.d(indices{:});
sys.lti = sys.lti(indices{:});

% Note: don't systematically reduce the subsystem with MINSTRUCT
%       (this messes up applications like LQG design where gain and 
%       estimators need to be designed with same number of states, cf
%       MILLDEMO)




