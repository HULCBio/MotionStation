function [a,b1,b2,c1,c2,d11,d12,d21,d22]=sec2tss(sec,dim)
%SEC2TSS Convert sectors into two-port dynamical sectors (used by SECTF).
%
% TSS_ = SEC2TSS(SEC) or TSS_ = SEC2TSS(SEC,DIM) or
% [A,B1,B2,C1,C2,D11,D12,D21,D22] = SEC2TSS(SEC) or
% [A,B1,B2,C1,C2,D11,D12,D21,D22] = SEC2TSS(SEC,DIM)
%
% SEC2TSS is a subroutine used by SECTF for converting
% constant sectors into general two-port dynamical sectors.

% R. Y. Chiang & M. G. Safonov 3/06/92
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

% SEC2TSS converts a constant sector specification SEC into the
% general dynamical `tss' two-port state-space SYSTEM form
%     TSS_=MKSYS([],[],[],[],[],SEC11,SEC12,SEC21,SEC22,'tss');
% The following formats for the matrix SEC are handled:
%  SECTOR INEQUALITY:     |  SEC =       | COMMENTS:
% ------------------------|-------------------------------------------
%  <Y-AU,Y-BU> <0         |  [A,B]       |  A,B are scalars or
%                         |  [A;B]       |  square DIMxDIM matrices
% --------------------------------------------------------------------
%  <Y-diag(A)U,Y-diag(B)U>|  [A',B']     |  A,B are vectors of
%            <0           |  [A;B]       |  length DIM
% --------------------------------------------------------------------
% <SEC11*U+SEC12*BY,      |[SEC11 SEC12  |  SEC11,SEC12,SEC21,SEC22
%    SEC21*U+SEC22*Y> < 0 | SEC21 SEC22] |  square DIMxDIM matrices
% --------------------------------------------------------------------
% If nargin==1, then DIM defaults to DIM=max(size(SEC))/2.



% Case SEC is already in `tss' SYSTEM form, pass
% argument(s) to output and return:

if issystem(sec)
  if issame(branch(sec,'ty'),'tss'),
    if nargout<2,
       a=sec;
    else
       [a,b1,b2,c1,c2,d11,d12,d21,d22]=branch(sec);
    end
    return
  end
end

[r,c]=size(sec);

% Default value of DIM:
if nargin<2
   dim=max([r,c])/2;
end
x1=1:dim;x2=dim+1:2*dim;


% Initialize abflag=0; later set to 1 if sector is [a,b] form:
abflag=0;

if min([r,c])==1 & max([r,c])==2
% Case of scalar a,b
       d11=diag(sec(1)*ones(dim,1)); d12=-eye(dim);
       d21=diag(sec(2)*ones(dim,1)); d22=-eye(dim);
       abflag=1;
elseif min([r,c])==1 & max([r,c])==2*dim,
% Case of vector SEC=[a;b] or SEC=[a',b']
       d11=diag(sec(x1));d12=-eye(dim);
       d21=diag(sec(x2));d22=-eye(dim);
       abflag=1;
elseif r==2 & c==2,
% Case of scalar SEC11,SEC12,SEC21,SEC22:
       d11=sec(1,1)*eye(dim);  d12=sec(1,2)*eye(dim);
       d21=sec(2,1)*eye(dim);  d22=sec(2,2)*eye(dim);
elseif 2*r==c & r==dim
% Case of SEC=[A;B] with A,B square matrices
       d11=sec(x1,x1);         d12=-eye(dim);
       d21=sec(x1,x2);         d22=-eye(dim);
       abflag=1;
elseif r==2*c & c==dim,
% Case of SEC=[A,B] with A,B square matrices
       d11=sec(x1,x1);         d12=-eye(dim);
       d21=sec(x2,x1);         d22=-eye(dim);
       abflag=1;
elseif r==c & c==2*dim,
% Case of SEC = [A,B;C,D] with A,B square matrices
       d11=sec(x1,x1);         d12=sec(x1,x2);
       d21=sec(x2,x1);         d22=sec(x2,x2);
else          % Case of SEC with invalid dimenions
  txt1='SIZE(SEC) is incompatible with DIM:';
  txt2='try SEC=[A;B] with A and B either scalars, vectors of length DIM,';
  txt3='   or square matrices of size DIMxDIM.';
  cr= [13 10];   % carriage return and new line
  error([txt1 cr txt2 cr txt3])
end

% Correctly handle sectors with A or B + or - INF:
if abflag,
  if 1e6*(min(max(d11)))==Inf,
     % Case A=Inf
     d11=(2*norm(d21)+1)*eye(dim); d12=zeros(dim,dim);
  end
  if 1e6*(min(max(d21)))==Inf,
     % Case B=Inf
     d21=(2*norm(d11)+1)*eye(dim); d22=zeros(dim,dim);
  end

  if 1e6*(max(min(d11)))==-Inf,
     % Case A=-Inf
     d11=-(2*norm(d21)+1)*eye(dim); d12=zeros(dim,dim);
  end
  if 1e6*(max(min(d21)))==-Inf,
     % Case A=-Inf
     d21=-(2*norm(d11)+1)*eye(dim); d22=zeros(dim,dim);
  end
end



[ny1,nu2]=size(d12);
[ny2,nu1]=size(d21);
% Now add empty state-space a,b,c matrices:
a=[];
b1=zeros(0,nu1);
b2=zeros(0,nu2);
c1=zeros(ny1,0);
c2=zeros(ny2,0);

% If nargout<2 convert output to SYSTEM format:
if nargout<2,
   at=mksys(a,b1,b2,c1,c2,d11,d12,d21,d22,'tss');
end


% ------------------- End of SEC2TSS.M -----------------RYC/MGS 03/06/92