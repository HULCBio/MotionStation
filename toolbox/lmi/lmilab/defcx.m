% [V1,...,Vk] = defcx(lmisys,n,X1,....,Xk)
%
%
% Returns the values  V1,...,Vk  of the matrix variables
% labeled  X1,...,Xk  when the N-th decision variable is
% set to 1 and all others to 0.
%
% This function is useful to derive the C vector used
% by the LMI solver MINCX (see the User's Guide for
% details)
%
%
% See also  MINCX, MAT2DEC, DECINFO.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,...
                                   V13,V14,V15,V16,V17,V18,V19,V20]=...
          defcx(LMIsys,n,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,...
                                     X13,X14,X15,X16,X17,X18,X19,X20);


if nargin <3,
  error('usage: [V1,...,Vk] = defcx(lmisys,n,X1,....,Xk)');
elseif nargout > 2+nargin,
  error('Two many output arguments');
elseif nargin > 22,
  error('DEFCX can only handle 20 matrix variables at a time');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
elseif n<0 | n>decnbr(LMIsys),
  error('N is out of range')
end


[LMI_set,LMI_var]=lmiunpck(LMIsys);

if isempty(LMI_var),
  error('LMISYS contains no matrix variable description');
end


for h=1:nargin-2,

  klb=eval(['X' num2str(h)]);  % variable label
  if klb<=0 | klb>max(LMI_var(1,:)),
    error(sprintf('The identifier X%d is out of range',h));
  end

  var=LMI_var(:,find(LMI_var(1,:)==klb));
  type=var(2);
  base=var(3);  last=var(4);
  row=var(5);   col=var(6);


  V=zeros(row,col);

  if n > base & n <= last & type==1,

    nblocks=var(7);
    struct=var(8:7+2*nblocks);
    decb=base;   % dec base for the block under scrutiny
    rowb=0; k=1;

    while n > decb,
      siz=struct(2*k-1);
      if struct(2*k)==0,        % scalar block
         if n==decb+1,
            V(rowb+1:rowb+siz,rowb+1:rowb+siz)=eye(siz);
         end
         decb=decb+1;
      elseif struct(2*k)==1,    % full block
	 nvar=siz*(siz+1)/2;
         rk=n-decb;
         if rk <= nvar,
            i=ceil((-1+sqrt(1+8*rk))/2);
            j=rk-i*(i-1)/2;
            V(rowb+i,rowb+j)=1; V(rowb+j,rowb+i)=1;
         end
         decb=decb+nvar;
      end
      rowb=rowb+siz;
      k=k+1;
    end

  elseif n > base & n <= last & type==2,   % rectangular

    n0=n-base;
    i=ceil(n0/col);
    j=n0-(i-1)*col;
    V(i,j)=1;

  elseif n > base & n <= last		    % special

    struct=var(7:6+row*col);
    ind=find(abs(struct)==n);
    V=zeros(size(struct));   V(ind)=ones(length(ind),1);
    V=ve2ma(sign(struct).*V,2,[row,col]);

  end

  eval(['V' num2str(h) '=V;']);


end
