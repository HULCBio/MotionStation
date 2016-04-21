% [lhs,rhs]=showlmi(lmisys,n)
%
% Returns the matrix value of the left-hand side LHS and
% right-hand side RHS of the N-th LMI.
% All variables must have been preliminarily instantiated
% with either SETMVAR or EVALLMI
%
% Input:
%   LMISYS   array describing the set of evaluated LMIs
%	     (output of EVALLMI)
%   N 	     label of the selected LMI as returned by
%            NEWLMI
%
%
% See also  EVALLMI, LMIINFO, LMIEDIT.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [lhs,rhs]=showlmi(LMIsys,n)

if nargin ~= 2,
   error('usage: [lhs,rhs] = showlmi(lmisys,n)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end

[LMI_set,LMI_var,LMI_term,data]=lmiunpck(LMIsys);


% get record on spec. LMI
lmi=LMI_set(:,find(LMI_set(1,:)==n));

if isempty(lmi),
   error('the argument N is out of range');
elseif isempty(LMI_term),
   lhs=zeros(lmi(2)); rhs=lhs; return
elseif length(find(LMI_term(4,:)~=0)) > 0,
   error('Not all variables have been instantiated');
end

insize=lmi(3);
if lmi(2)>0, outsize=lmi(2); else outsize=insize; end
blckdims=lmi(7:6+lmi(6))';
blckdims=max([blckdims;ones(1,length(blckdims))]);

trange = lmi(4):lmi(5);
if isempty(trange) | ~any(trange),
   lhs=zeros(lmi(2));  rhs=lhs;  return
else
   lmit=LMI_term(:,lmi(4):lmi(5));
end

lhs=lmicte(lmit,data,blckdims,insize,n);
rhs=lmicte(lmit,data,blckdims,insize,-n);


% retrieve the outer factors and multiply

f=lmit(:,find(lmit(1,:)==n & lmit(2,:)==0));

if max(max(abs(lhs)))==0,
   lhs=zeros(outsize);
elseif ~isempty(f),
   % get left outer factor
   N=lmicoef(f,data);
   lhs=N'*lhs*N; lhs=(lhs+lhs')/2;
end

f=lmit(:,find(lmit(1,:)==-n & lmit(2,:)==0));

if max(max(abs(rhs)))==0,
   rhs=zeros(outsize);
elseif ~isempty(f),
   % get right outer factor
   N=lmicoef(f,data);
   rhs=N'*rhs*N; rhs=(rhs+rhs')/2;
end
