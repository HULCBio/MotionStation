function sys = subsasgn(sys,Struct,rhs)
%SUBSASGN  Subscripted assignment for LTI objects.
%
%   The following assignment operations can be applied to any 
%   LTI model SYS: 
%     SYS(Outputs,Inputs)=RHS  reassigns a subset of the I/O channels
%     SYS.Fieldname=RHS        equivalent to SET(SYS,'Fieldname',RHS)
%   The left-hand-side expressions can be themselves followed by any 
%   valid subscripted reference, as in SYS(1,[2 3]).inputname='u' or
%   SYS.num{1,1}=[1 0 2].
%
%   For arrays of LTI models, indexed assignments take the form
%      SYS(Outputs,Inputs,j1,...,jk) = RHS
%   where k is the number of array dimensions (in addition to the
%   input and output dimensions).
%
%   See also SET, SUBSREF, LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.27 $  $Date: 2002/04/10 06:11:50 $

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
   error(sprintf('Unknown type: %s',Struct(1).type));
end


% Subfunction INDEXASGN: Reassigns sys(indices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexasgn(sys,indices,rhs)
%INDEXASGN   Reassigns sys(indices)

% Handle case sys=[] (case when SYS is created by subsasgn statement)
if isa(sys,'double'),
   % Initialize to empty ZPK
   sys = zpk;
end
sizes = size(sys.k);   % sizes of sys
DelFlag = isequal(rhs,[]);  % flags deletions SYS(INDICES)=[]

% Check and format indices
indices = asgnchk(indices,sizes,DelFlag,sys.lti);

% Handle case SYS(i1,...,ik) = [] separately
if DelFlag,
   % Delete parts of system SYS
   sys.z(indices{:}) = [];
   sys.p(indices{:}) = [];
   sys.k(indices{:}) = [];
   sys.lti = ltiasgn(sys.lti,indices,[]);
   return
end

% Left with case SYS(i1,...,ik) = RHS.
% Get RHS data
if isa(rhs,'double'),
   % RHS is an array. 
   rk = rhs;
   rz = cell(size(rk));  rz(:) = {zeros(0,1)};  
   rp = rz;  
   sflags = [isstatic(sys) , 1];  % 1 when static gains
   rlti = lti(1,1);   % same as scalar assignment from LTI viewpoint
   zerorhs = ~any(rhs(:));
else
   % RHS is LTI
   rhs = zpk(rhs);  % convert to zpk
   rz = rhs.z;  
   rp = rhs.p;  
   rk = rhs.k;
   sflags = [isstatic(sys) , isstatic(rhs)];  
   rlti = rhs.lti;
   zerorhs = ~any(rk(:));
end
rsizes = size(rk);      % sizes of rhs

% Update Z,P,K. Rely on ND assignment code to detect errors
sys.z(indices{:}) = rz;
sys.p(indices{:}) = rp;
sys.k(indices{:}) = rk;

% Prohibit sys(1,2,1:10) = 1x10 ZPK (should be 1x1x10 to preserve I/O dims)
if isa(rhs,'lti') & ~all(rsizes==1),
   % Get first two dimensions LSIZES of the assigned portion of the LHS
   lsizes = size(sys.k);  % use current sizes in case LHS created by assignment
   for j=find(~strcmp(indices(1:2),':')),  % non-colon indices
      if islogical(indices{j}),
         lsizes(j) = length(find(indices{j}));
      else
         lsizes(j) = length(indices{j});
      end
   end
   if ~isequal(rsizes(1:2),lsizes(1:2)),
      error('I/O dimension mismatch in LTI assignment.')
   end
end

% Replace [] by zeros(0,1) if SYS was resized
if ~isequal(size(sys.k),sizes),
   Emptys = (cellfun('size',sys.z(:),1)==0 & cellfun('size',sys.z(:),2)==0);
   sys.z(Emptys) = {zeros(0,1)};  
   sys.p(Emptys) = {zeros(0,1)};
end


% LTI property management:
% (1) Adjust sample time of static gains to avoid unwarranted clashes
%     RE: static gains are regarded as sample-time free
if any(sflags),
   [sys.lti,rlti] = sgcheck(sys.lti,rlti,sflags);
end

% (2) Update LTI properties of LHS
sys.lti = ltiasgn(sys.lti,indices,rlti,sizes,size(sys.k),rsizes,zerorhs);


% Keep Variable & DispplayFormat of SYS unless SYS was a static gain
if sflags(1) & ~sflags(2),
   sys.DisplayFormat = rhs.DisplayFormat;
   sys.Variable = rhs.Variable;
end
