% X = dec2mat(lmisys,decvars,k);
%
% Given the value DECVARS  of the vector of decision variables,
% DEC2MAT returns  the corresponding matrix value X of the K-th
% matrix variable (more generally, of the variable of label K).
% Note that DECVARS is typically the output of some optimization
% procedure.
%
% Input:
%   LMISYS     array describing the system of LMIs
%   DECVARS    vector of decision variable values
%   K	       identifier of the variable matrix of interest
%              as returned by LMIVAR
%
% Output:
%   X          matrix value of Xk
%
%
% See also  MAT2DEC, DECINFO, DECNBR, LMIVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function X=dec2mat(LMIsys,decvars,k);


if nargin ~= 3,
  error('usage: X = dec2mat(LMISYS,decvars,k)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end



decvars=decvars(:);
decn=decnbr(LMIsys);
if length(decvars)~=decn,
  error(sprintf('DECVARS must be a vector of length %d',decn));
end


[LMI_set,LMI_var]=lmiunpck(LMIsys);

if isempty(LMI_var),
  error('No matrix variable description in LMISYS');
elseif isempty(k),
  error('K must be nonempty');
elseif k<=0 | k>max(LMI_var(1,:)),
  error('K is out of range');
end


varrec=LMI_var(:,find(LMI_var(1,:)==k));
type=varrec(2);
base=varrec(3); last=varrec(4);
row=varrec(5);   col=varrec(6);

lfreev=length(decvars);


if type==1,

  if base>=lfreev | last>lfreev,
     error('Length of DECVARS too short!');
  end

  nblocks=varrec(7);
  struct=varrec(8:7+2*nblocks);
  decvars=decvars(base+1:last);
  first=1; X=[];

  for k=1:nblocks,
     siz=struct(2*k-1);
     if struct(2*k)==0,		% scalar block
	X=mdiag(X,decvars(first)*eye(siz,siz));
	first=first+1;
     elseif struct(2*k)==1,     % full symmetric bloc
	nvar=siz*(siz+1)/2;
	X=mdiag(X,ve2ma(decvars(first+(0:nvar-1)),1));
	first=first+nvar;
     else                       % zero block
        X=mdiag(X,zeros(siz));
     end
  end

elseif type==2,		% rectangular

  if base>=lfreev | last>lfreev,
     error('Length of DECVARS too short!');
  end

  X=ve2ma(decvars(base+(1:row*col)),2,[row,col]);

else			% special

  struct=varrec(7:6+row*col);

  if ~isempty(find(struct>lfreev)),
     error('Length of DECVARS too short!');
  end

  decvars=[0 ; decvars];
  X=decvars(abs(struct)+ones(size(struct)));
  X=ve2ma(sign(struct).*X,2,[row,col]);

end
