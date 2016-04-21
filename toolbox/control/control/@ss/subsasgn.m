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

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.30.4.1 $  $Date: 2002/11/11 22:22:06 $

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Subfunction INDEXASGN: Reassigns sys(indices)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexasgn(sys,indices,rhs)

% Handle case sys=[] (case when SYS is created by subsasgn statement)
CreateLHS = 0;
if isa(sys,'double'),
   % Initialize to empty SS
   sys = ss;
   CreateLHS = 1;
end
sizes = size(sys.d);   % sizes of sys
DelFlag = isequal(rhs,[]);

% Check and format indices
indices = asgnchk(indices,sizes,DelFlag,sys.lti);

% Handle case sys(i1,...,ik) = [] separately
% RE: * state vector left untouched
%     * for sys(:,:,:)=[], only delete outputs to mimic a(:,:,:)=[] for matrices
if DelFlag,
   nci = find(~strcmp(indices,':'));  % empty or contains single index
   % Update A,B,C,E data
   if isempty(nci) | nci==1,
      % Delete outputs
      for k=1:prod(sizes(3:end)),
         sys.c{k}(indices{1:2}) = [];
      end
   elseif nci==2,
      % Delete inputs
      for k=1:prod(sizes(3:end)),
         sys.b{k}(indices{1:2}) = [];
      end
   else
      % Delete models
      sys.a(indices{3:end}) = [];
      sys.b(indices{3:end}) = [];
      sys.c(indices{3:end}) = [];
      sys.e(indices{3:end}) = [];
      sys.e = ematchk(sys.e);
   end
   sys.d(indices{:}) = [];
   sys.lti = ltiasgn(sys.lti,indices,[]);
   return
end


% Left with case sys(i1,...,ik) = rhs
% -----------------------------------
% Get RHS data
if isa(rhs,'double'),
   % RHS is an double array. 
   d = rhs;
   rnames = cell(0,1);
   sflags = [isstatic(sys) , 1];  % 1 when static gains
   rlti = lti(1,1);   % same as scalar assignment from LTI viewpoint
   zerorhs = ~any(rhs(:));
else
   % RHS is LTI
   rhs = ss(rhs); % convert to SS
   d = rhs.d;
   rnames = rhs.StateName;
   sflags = [isstatic(sys) , isstatic(rhs)];  
   rlti = rhs.lti;
   EmptyA = cellfun('isempty',rhs.a);
   zerorhs = all(EmptyA(:)) & ~any(rhs.d(:));
end
rsizes = size(d); % sizes of rhs

% Update D matrix of LHS. Rely on ND assignment code to detect errors.
sys.d(indices{:}) = d;
newsizes = size(sys.d);
if any(rsizes~=1) && isa(rhs,'double')
   % Update RHS size info (Watch for sys(:,:,[1 2],[3 4]) = [1 2;3 4])
   rsizes = size(sys.d(indices{:}));
end

% List of reassigned models
if length(indices)>2,
   % Keep track of rhs model associated with each modified lhs model
   % (necessary because indices are not always monotonic, see g147948)
   LHSModels = zeros([newsizes(3:end) 1 1]);
   ras = [rsizes(3:end) 1 1];
   LHSModels(indices{3:end}) = reshape(1:prod(ras),ras);
   % idxLHSModels -> which lhs models are reassigned (absolute indices, monotonic)
   % idxRHSModels -> idxRHSModels(k) = rhs model assigned to idxLHSModels(k)
   idxLHSModels = find(LHSModels(:));
   idxRHSModels = LHSModels(idxLHSModels);
else
   idxLHSModels = 1;
   idxRHSModels = 1;
end
nac = size(sys.d(indices{1:2},1));  % number of reassigned channels
nam = length(idxLHSModels);         % number of reassigned models

% Resize B,C data in SYS if assignment increases I/O dimensions
if newsizes(1)>sizes(1),
   % Increased number of outputs
   for k=1:prod(sizes(3:end)),
      sys.c{k} = [sys.c{k} ; zeros(newsizes(1)-sizes(1),size(sys.c{k},2))];
   end
end
if newsizes(2)>sizes(2),
   % Increased number of inputs
   for k=1:prod(sizes(3:end)),
      sys.b{k} = [sys.b{k} , zeros(size(sys.b{k},1),newsizes(2)-sizes(2))];
   end
end

% Derive state-space data for RHS 
if isa(rhs,'double'),
   % Shape A,B,C,E adequately when RHS is not LTI. Cf. difference
   % between sys(1,2,:) = ones(20,1)  and  sys(:,:,3) = ones(2) )
   a = {[]};  
   e = {[]};  
   b = {zeros(0,nac(2))};
   c = {zeros(nac(1),0)};
else
   % RHS is LTI
   a = rhs.a(:);
   e = rhs.e(:);
   b = rhs.b(:);
   c = rhs.c(:);
   if any(rsizes(1:2)~=1) & ~isequal(nac,rsizes(1:2)),
      % Prohibit sys(1,2,1:60) = ss(ones(1,60))
      error('I/O dimension mismatch in LTI assignment.')
   elseif all(rsizes(1:2)==1) & any(nac>1),
      % RHS is a single scalar LTI or an array of scalar LTIs
      % Resize B and C matrices to match NAC
      for k=1:prod(rsizes(3:end)),
         b{k} = b{k}(:,ones(1,nac(2)));
         c{k} = c{k}(ones(1,nac(1)),:);
      end
   end
end

% Resize LHS A,B,C,E if assignment increases array sizes
if prod(newsizes(3:end))>prod(sizes(3:end)),
   LastModel = num2cell([newsizes(3:end) 1 1]);
   sys.a(LastModel{:}) = {[]};
   sys.e(LastModel{:}) = {[]};
   sys.b(LastModel{:}) = {[]};
   sys.b(~cellfun('size',sys.b(:),1)) = {zeros(0,newsizes(2))};
   sys.c(LastModel{:}) = {[]};
   sys.c(~cellfun('size',sys.c(:),2)) = {zeros(newsizes(1),0)};
end

% Perform assignment
[sys.e,e] = ematchk(sys.e,sys.a,e,a);  
for k=1:nam,
   klhs = idxLHSModels(k);
   krhs = min(idxRHSModels(k),prod(size(a)));
   [sys.a{klhs},sys.b{klhs},sys.c{klhs},sys.e{klhs},NewStateName] = ...
      blockasgn(indices{1},indices{2},...
      sys.a{klhs},sys.b{klhs},sys.c{klhs},sys.e{klhs},sys.StateName,...
      a{krhs},b{krhs},c{krhs},e{krhs},rnames);
end
sys.e = ematchk(sys.e);

% Update state names 
Nx = size(sys,'order');
if length(Nx)==1,
   % Use new names unless old names still apply to part of the models
   if Nx~=length(sys.StateName) | ...
         all(strcmp(sys.StateName,'')) | ...
         nam==prod(newsizes(3:end))
      sys.StateName = NewStateName;
   end
else
   sys.StateName = repmat({''},[max(Nx(:)),1]);
end

% LTI property management:
% (1) Adjust sample time of static gains to avoid unwarranted clashes
%     RE: static gains are regarded as sample-time free
if any(sflags),
   [sys.lti,rlti] = sgcheck(sys.lti,rlti,sflags);
end

% (2) Update LTI properties of LHS
sys.lti = ltiasgn(sys.lti,indices,rlti,sizes,newsizes,rsizes,zerorhs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,E,Sn] = blockasgn(arows,acols,A,B,C,E,Sn,a,b,c,e,sn)
%BLOCKASGN  Single-model assignment.
% 
%   Given SYS:(A,B,C,E) and RHS:(a,b,c,e), BLOCKASGN computes
%   a realization for SYS after the assignment
%      SYS(AROWS,ACOLS,:) = RHS
%
%   Note: Resulting A has as many or more states than incoming A.

% Map AROWS and ACOLS to integer indices
P = size(C,1);
if isstr(arows),
   arows = 1:P;
elseif islogical(arows),  
   arows = find(arows);  
end
   
M = size(B,2);
if isstr(acols),
   acols = 1:M;
elseif islogical(acols),  
   acols = find(acols);  
end

% Quick exit if only D matrix is affected by assignment
if isempty(arows) | isempty(acols) | ...
      (isequal(A,a) & isequal(E,e) & ...
      isequal(B(:,acols),b) & isequal(C(arows,:),c)),
   return
end

% Get row and column indices not affected by assignment, and
% implicitly permute I/O so that the assignment looks like 
%    [sys11  sys12 ;         [sys11  sys12;
%     sys21  sys22 ]   -->    sys21   rhs ]
frows = 1:P;  frows(arows) = [];   % fixed rows
fcols = 1:M;  fcols(acols) = [];   % fixed rows
rperm = [frows , arows];           % row permutation
cperm = [fcols , acols];           % column permutation

% Loop over each model
Na = size(A,1);
na = size(a,1);
Ne = size(E,1);
D0 = zeros(P,M);
d = D0(arows,acols);

if isempty(frows) & isempty(fcols),
   % Full reassignment
   A = a;  E = e;  B = b;  C = c;  Sn = sn;  
   
else
   % Split B and C
   B1 = B(:,fcols);   B2 = B(:,acols);
   C1 = C(frows,:);   C2 = C(arows,:);
   
   % Compute structural order of [[sys11 sys12] ; [sys21 rhs]]
   [Ar1,Br1,Cr1,Er1,Snr1] = smreal(A,[B1 B2],C1,E,Sn(1:Na));
   [A21,B21,C21,E21,Snr2] = smreal(A,B1,C2,E,Sn(1:Na,1));
   Naug1 = size(Ar1,1) + size(A21,1);
   
   % Compute structural order of [[sys11 ; sys21] , [sys12 ; rhs]]
   [Ac1,Bc1,Cc1,Ec1,Snc1] = smreal(A,B1,[C1;C2],E,Sn(1:Na));
   [A12,B12,C12,E12,Snc2] = smreal(A,B2,C1,E,Sn(1:Na,1));
   Naug2 = size(Ac1,1) + size(A12,1);
   
   % Derive realization (A,B,C,E) of SYS
   % RE: We don't care about D since it's already updated
   if Naug1<=Naug2,
      % Assemble result as [[sys11 sys12] ; [sys21 rhs]]
      [A,B,C,D,E] = ...
         ssops('hcat',A21,B21,C21,D0(arows,fcols),E21,a,b,c,d,e); 
      [A,B,C,D,E] = ...
         ssops('vcat',Ar1,Br1,Cr1,D0(frows,[fcols acols]),Er1,A,B,C,D,E); 
      Sn = [Snr1 ; Snr2 ; sn(1:na,1)];            
   else
      % Assemble result as [[sys11 ; sys21] , [sys12 ; rhs]]
      [A,B,C,D,E] = ...
         ssops('vcat',A12,B12,C12,D0(frows,acols),E12,a,b,c,d,e); 
      [A,B,C,D,E] = ...
         ssops('hcat',Ac1,Bc1,Cc1,D0([frows arows],fcols),Ec1,A,B,C,D,E); 
      Sn = [Snc1 ; Snc2 ; sn(1:na,1)];
   end
end

% Reorder rows and columns of C and B
B(:,cperm) = B;     
C(rperm,:) = C;

