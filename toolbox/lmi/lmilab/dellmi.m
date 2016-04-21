% newsys = dellmi(lmisys,lmid)
%
% Removes the LMI of label LMID  from the system of LMIs
% described in LMISYS.   LMID is the ranking of the LMI in
% the intial system created with NEWLMI. To easily keep track
% of LMI deletions, set LMID to the identifier returned by
% NEWLMI when this LMI was created.
%
% Matrix variables that appeared only in this LMI are
% automatically removed.
%
% Input:
%   LMISYS         array describing the system of LMIs
%   LMID           identifier of the LMI to be deleted
%                  (as returned by NEWLMI)
% Output:
%   NEWSYS         updated description of the LMI system.
%
%
% See also  NEWLMI, DELMVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function NEWsys=dellmi(LMIsys,lmID)

if nargin~=2,
  error('usage: newsys = dellmi(lmisys,lmID)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end

[LMI_set,LMI_var,LMI_term,data]=lmiunpck(LMIsys);

if isempty(LMI_set), error('LMI system is empty'); end


lmirk=find(LMI_set(1,:)==abs(lmID));  % corresp. col # in LMI_set

if lmID<0 | isempty(lmirk),
  error('The LMI referred to by LMID does not exist');
end


% range of related terms in LMI_term
rgt=LMI_set(4,lmirk):LMI_set(5,lmirk);
lmit=LMI_term(:,rgt);

LMI_set(:,lmirk)=[];


% update LMI_term
%----------------
deldt=[];
if ~isempty(lmit),
  ind=find(abs(lmit(1,:))==lmID);
  deldt=[deldt,[rgt(ind);lmit(5:6,ind)]];
end

% update data
delrg=[];
for r=deldt,
  delrg=[delrg , r(2)+1:r(2)+r(3)];
end
data(delrg)=[];


LMI_term(:,deldt(1,:))=[]; nterms=size(LMI_term,2);
j=0; shft=zeros(1,nterms);
nlmis=size(LMI_set,2);


if isempty(LMI_term),
  if nlmis, LMI_set(4:5,:)=zeros(2,nlmis); end
  NEWsys=lmipck(LMI_set,[],[],[]);

else
  % update LMI_term(5),
  for t=LMI_term,
     j=j+1; shft(j)=sum(deldt(3,find(deldt(2,:)<t(5))));
  end
  LMI_term(5,:)=LMI_term(5,:)-shft;


  % update LMI_set
  dref=zeros(2,max(abs(LMI_set(1,:)))); j=0;
  for t=LMI_term,
    j=j+1; lmi=abs(t(1));
    if ~dref(1,lmi), dref(1,lmi)=j; end
    dref(2,lmi)=j;
  end
  for j=1:nlmis,
    LMI_set(4:5,j)=dref(:,LMI_set(1,j));
  end

  % update LMI_var by removing variables which appeared only
  % in the LMI # lmID

  NEWsys=lmipck(LMI_set,LMI_var,LMI_term,data);
  lmitv=abs(LMI_term(4,:));

  if ~isempty(LMI_var),
    ind=[];
    for j=LMI_var(1,:),
       if isempty(find(lmitv==j)), ind=[ind,j]; end
    end
    for k=ind,  % variables to be removed
       NEWsys=delmvar(NEWsys,k);
    end
   end
end
