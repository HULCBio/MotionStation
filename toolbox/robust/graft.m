function tr1=graft(tr,b,nm)
%GRAFT Add root branch onto "TREE" vector.
%
% TR1 = GRAFT(TR,B)
% TR1 = GRAFT(TR,B,NM) adds root branch B onto tree vector TR (previously
%     created by TREE or MKSYS). If TR has N branches then the numerical
%     index of the new root branch is N+1; and the numerical indices
%     of the other root branches are unchanged.  The string NM, if
%     present, becomes the name of the new root branch.  Related functions
%     include the following:
%         TREE     creates a tree
%         MKSYS    creates a tree containing matrices describing a system
%         BRANCH   returns branches of a tree
%         ISTREE   tests whether a variable is a tree or not
%         ISBRANCH tests whether a given branch of a tree exists
%

% R. Y. Chiang & M. G. Safonov 07/01/91
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

if nargin<2, error('must specify at least two input arguments'),end
if nargin<3, nm='';end

% Remove any spaces from NM
nm=[nm ' ']; nm(find(nm==' '))='';
% Now check name NM for validity
temp=find((nm>='0' & nm<='9')|(nm>='A' & nm<='Z')|nm=='_'|(nm>='a' & nm<='z'));
if min(size(nm))>0
   temp=nm(temp);
   if ~issame(temp,nm) | ~(nm(1)>=65),
     msg=...
     ['Third argument must be a string containing a valid MATLAB variable name.'];
     error(msg),
   end
end


if min(size(tr))==0,
   tr1=tree(nm,b);
   return,
end

if ~istree(tr)
 error('The second input argument must be a tree vector created by TREE or MKSYS'),
end

% Get HEADER, PTR, NM and DAT vectors from TR and determine pointer IND
c=max(size(tr));
header=tr(1:5);
n=header(1);  % number of branches in TR
ptr=tr(6:6+n);
dat=tr(7+n:c);

nm0=branch(tr,0);
% Determine length NM0 of original branch B0
if ptr(1)>6,
  [rnm0,cnm0]=size(nm0);
  lb0=2+cnm0;
else
  lb0=0;
end

% Get DAT1=[B1;...,BN]
dat1ptr0=n+7+lb0;
dat1=tr(dat1ptr0:c);


% Augment branch B0 with new branch name NM
nm0=branch(tr,0);   % old NM
[rnm0,cnm0]=size(nm0);
[rnm,cnm]=size(nm);
if cnm0>0,
  nm=[nm0 ','  nm];
else
  if cnm > 0,
    nm=[ ( ','*ones(1,n) )  nm];
  end
end
[rnm,cnm]=size(nm);
if cnm>0,
  b0=[-rnm;cnm; double(nm(:))];
else
  b0=[];
end
[lb0new,junk]=size(b0);
delta=lb0new-lb0+1;



% Now build branch B_{N+1}
% and add unadjusted pointer entry
[rb,cb]=size(b);
if max([rb,cb])==0,
   bn=[];
   ptr=[ptr;1];
else
   if isstr(b), rb=-rb;end         % Negative rb indicates string
   bn=[rb;cb;double(b(:))];
   ptr=[ptr;c+1];
end

% Update DAT vector
dat = [b0;dat1;bn];


% Update N  and HEADER
n=n+1;
header(1)=n;

% Update PTR(1) (which points to branch B0)
if lb0new>0,
  ptr(1)=n+7;  % points to branch B0 data
else
  ptr(1)=1;  % pointer for empty matrix is 1
end

% Update PTR(2:N+1)
temp=ptr(2:n+1);
i=find(temp>5);
nptr=max(size(i));
if min(size(i))>0,
   temp(i)=temp(i)+delta*ones(nptr,1);
end
ptr(2:n+1)=temp;



% Now assemble the tree vector TR
% Format:
% index     1        6       PTR(0)  ...      PTR(N)
      %     HEADER   PTR     B0dat   ...      BNdat ];
tr1 = 1*[header; ptr; dat];
% Note:  Multiplying TR by 1 unsets string bit, if needed

% ------ End of GRAFT.M --- RYC/MGS 10/05/90 %
