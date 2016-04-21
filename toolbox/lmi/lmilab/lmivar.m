% X = lmivar(type,struct)
% [X,ndec,Xdec] = lmivar(type,struct)
%
% Adds a new matrix variable X to the LMI system currently
% described.  A label X can be optionally attached to this
% new variable to facilitate future reference to it.
%
% Input:
%  TYPE     structure of X:
%		  1 -> symmetric block diagonal
%		  2 -> full rectangular
%		  3 -> other
%  STRUCT   additional data on the structure of X
%	     TYPE=1: the i-th row of STRUCT describes the i-th
%                    diagonal block of X
%		      STRUCT(i,1) -> block size
%		      STRUCT(i,2) -> block type, i.e.,
%                                     0 for scalar blocks t*I
%			              1 for full block
%                                    -1 for zero block
%	     TYPE=2: STRUCT = [M,N]  if X is a MxN matrix
%	     TYPE=3: STRUCT is a matrix of same dimension as X
%		     where STRUCT(i,j) is either
%		       0  if X(i,j) = 0
%		      +n  if X(i,j) = n-th decision variable
%		      -n  if X(i,j) = (-1)* n-th decision var
% Output:
%  X        Optional: identifier for the new matrix variable.
%           Its value is k if k-1 matrix variables have already
%           been declared.  This identifier is not affected by
%           subsequent modifications of the LMI system
%  NDEC     total number of decision variables so far
%  XDEC     entry-wise dependence of X on the decision variables
%           (Xdec = struct for Type 3)
%
%
% See also  SETLMIS, LMITERM, GETLMIS, LMIEDIT, DECINFO.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [varID,ndec,Xdec]=lmivar(type,struct)

global GLZ_HEAD GLZ_LMIV

if nargin~=2,
  error('usage: X = lmivar(type,struct)');
elseif ~any(type==[1 2 3]),
  error('TYPE must be either 1, 2, or 3');
elseif any(size(GLZ_HEAD)~=[10 1]),
  error('Use SETLMIS to initialize the LMI system');
end

L=GLZ_HEAD(2);  % number of variables currently defined

% get first dec. var available
if L==0, first=0; else first=max(GLZ_LMIV(4,:)); end

% label the new variable
if isempty(GLZ_LMIV), varID=1; else varID=max(GLZ_LMIV(1,:))+1; end

if type==1,			% symmetric block diagonal

   if size(struct,2)~=2,

      error('STRUCT must be a Nx2 matrix when TYPE=1');
   end

   s=struct(:,1);   		% block sizes
   btype=struct(:,2);           % block types
   nblocks=size(struct,1);

   if ~isempty(find(btype~=0 & btype~=1 & btype~=-1)),
      error('STRUCT(i,2) must be 0, 1, or -1 when TYPE=1');
   elseif nblocks==1 & btype==-1,
      error('This variable is the zero matrix');
   else
      nfree=sum((btype==0)+(btype==1).*s.*(s+1)/2);
      ndec=first+nfree;
      newvar=[varID;type;first;ndec;...
                   sum(s)*[1;1];nblocks;ma2ve(struct,2)];
   end

   if nargout==3,
     Xdec=[]; base=first;
     for t=struct',
       if ~t(2),          % scalar block
	 Xdec=mdiag(Xdec,(base+1)*eye(t(1))); base=base+1;
       elseif t(2)==1,	  % full symmetric bloc
	 nvar=t(1)*(t(1)+1)/2;
	 Xdec=mdiag(Xdec,ve2ma(base+1:base+nvar,1)); base=base+nvar;
       else               % zero block
         Xdec=mdiag(Xdec,zeros(t(1)));
       end
     end
   end

elseif type==2,			% full rectangular

   if size(struct,1)+size(struct,2) ~= 3,
      error('STRUCT must be a vector of length 2 when TYPE=2');
   else
      m=struct(1);   n=struct(2); ndec=first+m*n;
      newvar=[varID;type;first;ndec;m;n];
   end

   if nargout==3, Xdec=ve2ma(first+1:ndec,2,[m,n]); end


else				% other

   if isempty(struct) | max(max(abs(struct)))==0, varID=[]; return, end

   % detect symmetric patterns
   if isymm(struct), type=31; else type=32; end
   [m,n]=size(struct);
   %%% v4 code
   % vec(:)=struct';

   %%% v5 code
   tmpstruct = struct';
   vec = tmpstruct(:);

   first=min(abs(vec(find(vec))))-1;
   ndec=max(abs(vec));
   newvar=[varID;type;first;ndec;m;n;vec];

   Xdec=struct;

end


cdim=size(GLZ_LMIV,2); lnew=length(newvar);
if L==cdim,  % reallocate
  GLZ_LMIV(max(size(GLZ_LMIV,1),lnew),max(5,2*cdim))=0;
end

GLZ_LMIV(1:lnew,L+1)=newvar;
GLZ_HEAD(2)=GLZ_HEAD(2)+1;
