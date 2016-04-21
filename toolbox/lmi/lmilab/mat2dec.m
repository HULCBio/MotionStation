% decvars = mat2dec(lmisys,X1,X2,X3,...)
%
% For given values X1, X2, X3, ... of the matrix variables
% involved in the LMI system LMISYS, MAT2DEC computes the
% value DECVARS of the vector of decision variables. This
% operation is the converse of that performed by DEC2MAT
%
% Input:
%    LMISYS     array describing the LMI system
%    X1, X2, X3,...
%               values of the matrix variables. MAT2DEC
%               accepts up to 20 values. An error is issued
%               if some matrix variable remains unassigned.
% Output:
%    DECVARS    vector of the decision variable values.
%
%
% See also  DEC2MAT, DECINFO, DEFCX.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function decvars=mat2dec(LMIsys,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,...
X13,X14,X15,X16,X17,X18,X19,X20);


if nargin < 2,
  error('usage: decvars = mat2dec(lmisys,X1,X2,X3,...)');
elseif nargin > 21,
  error('MAT2DEC accepts only up to 20 matrix variables');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end

[LMI_set,LMI_var]=lmiunpck(LMIsys);
nvars=size(LMI_var,2);

if ~nvars,
  error('No matrix variable defined in LMISYS');
elseif nargin-1 ~= nvars,
  error(sprintf(['There should be ' int2str(nvars) ...
                 ' matrix variable(s) in the calling list']));
end


ldec=decnbr(LMIsys);
decvars=zeros(ldec,1);
for k=1:ldec, decvars(k)=Inf; end
% Inf to keep track of what is already instantiated

k=0;

for var=LMI_var,

  k=k+1;
  eval(['X = X' int2str(k) ';']);
  type=var(2);
  base=var(3);   % base first dec var
  last=var(4);   % last dec var
  row=var(5);    col=var(6);

  % check dimensioning consistency
  if size(X,1)*size(X,2)==1,            % Xk = scalar
     if row==col,    X=X*eye(row);
     elseif X==0,    X=zeros(row,col);
     else
       error(['The argument X',num2str(k),' cannot be a scalar!']);
     end
  elseif size(X,1)~=row | size(X,2)~=col,
     error(['The argument X',num2str(k),' is not properly dimensioned!']);
  end


  if type==1,
    dec=[]; rcb=0;
    for l=1:var(7),
      bsize=var(6+2*l);
      btype=var(7+2*l);
      if btype==1,      % block type = 1
        dec=[dec;ma2ve(X(rcb+(1:bsize),rcb+(1:bsize)),1)];
      elseif btype==0,
        dec=[dec;X(rcb+1,rcb+1)];
      end
      rcb=rcb+bsize;
    end
    decvars(base+1:last)=dec;
  elseif type==2,
    decvars(base+1:last)=ma2ve(X,2);
  else
    struct=var(7:6+row*col);
    Xvec=X';   Xvec=Xvec(:);
    ind=find(abs(struct)>0);
    struct=struct(ind)'; Xvec=Xvec(ind)';

    for t=[struct;Xvec],
      n=abs(t(1));
      if decvars(n)==Inf, decvars(n)=sign(t(1))*t(2); end
    end
  end

  % check structure consistency
  lmitmp=lmipck([],var,[],[]);
  lmitmp(8)=ldec;
  Xs=dec2mat(lmitmp,decvars,var(1));
  if norm(X-Xs,1) > mach_eps^(3/4)*norm(X,1),
     error(['The argument X',num2str(k),' is not properly structured']);
  end

end


ind=find(decvars==Inf);
decvars(ind)=zeros(length(ind),1);
