% decinfo(lmisys)
% decX = decinfo(lmisys,X)
%
% Displays the matrix variable structure as well as its
% entry-wise dependence on the decision variables x1,...,xN
% (the free scalar variables in the LMI problem).
%
% The distribution of x1,...,xN in the matrix variable X is
% described by the integer matrix  DECX  with the following
% convention:
%    DECX(i,j)=0   means that   X(i,j) is a hard zero
%    DECX(i,j)=n   means that   X(i,j) = xn  (n-th dec. var.)
%    DECX(i,j)=-n  means that   X(i,j) = -xn
%
% When called with only one argument, DECINFO works as an
% interactive query/answer facility.
%
% Input:
%   LMISYS     internal description of the LMI system
%   X          identifier of the variable matrix of interest
%              (see LMIVAR)
% Output:
%   DECX       entry-wise dependence of X on x1,...,xN
%
%
% See also  DECNBR, DEC2MAT, MAT2DEC, LMIVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function decXk=decinfo(LMIsys,k);


if ~any(nargin == [1,2]),
  error('usage: decinfo(lmis)  or  decX=decinfo(lmis,X)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end

[LMI_set,LMI_var]=lmiunpck(LMIsys);

if isempty(LMI_var),
  error('No matrix variable described in LMISYS');
end

if nargin==1,  % interactive mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k=-1;
ndec=max(LMI_var(4,:));

disp(sprintf(['\nThere are ',num2str(ndec),...
' decision variables labeled x1 to x',num2str(ndec),' in this problem.\n']));


while k==-1,

  disp(sprintf(...
      ['\nMatrix variable Xk of interest ' ...
       '(enter k between 1 and %d, or 0 to quit):'],...
       size(LMI_var,2)));

  k=input(' ?> ');


  if k<0  | k > size(LMI_var,2),
     k=-1;
  elseif k,
     var=LMI_var(:,k);
     klb=var(1);
     base=var(3); last=var(4);

     if last-base==1,
     disp(sprintf(['\n The only decision variable in X',num2str(k),...
             ' is x',num2str(base+1),'.']));
     disp(sprintf([' Its entry-wise distribution in X',num2str(k),...
             ' is as follows\n',...
             '         (0,j,-j  stand for 0,xj,-xj, respectively):']));
     else
     disp(sprintf(['\n The decision variables in X',num2str(k),...
             ' are among {x',num2str(base+1),',...,x',...
              num2str(last),'}.']));
     disp(sprintf([' Their entry-wise distribution in X',num2str(k),...
             ' is as follows\n',...
             '         (0,j,-j  stand for 0,xj,-xj, respectively):']));
     end

     disp(sprintf(['\n X' num2str(k) ' : \n']))
     disp(decinfo(LMIsys,klb))
     disp('              *********');

     k=-1;
  end

end




else
%%%%



if isempty(find(k==LMI_var(1,:))),
    error('Unknown variable identifier X')
end


var_record=LMI_var(:,find(LMI_var(1,:)==k));
if isempty(var_record), decXk=[]; return, end
type=var_record(2);
base=var_record(3); last=var_record(4);
row=var_record(5);   col=var_record(6);


if type==1,

  nblocks=var_record(7);
  struct=var_record(8:7+2*nblocks);
  decXk=[];

  for k=1:nblocks,
     siz=struct(2*k-1);
     if struct(2*k)==0,		  % scalar block
	decXk=mdiag(decXk,(base+1)*eye(siz));
	base=base+1;
     elseif struct(2*k)==1,	  % full symmetric bloc
	nvar=siz*(siz+1)/2;
	decXk=mdiag(decXk,ve2ma(base+1:base+nvar,1));
	base=base+nvar;
     else                         % zero block
        decXk=mdiag(decXk,zeros(siz));
     end
  end

elseif type==2,		% rectangular

  decXk=ve2ma(base+1:base+row*col,2,[row,col]);

else			% special

  decXk=ve2ma(var_record(7:6+row*col),2,[row,col]);

end


end
%%%
