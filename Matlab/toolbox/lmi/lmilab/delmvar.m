% newsys = delmvar(lmisys,k)
%
% Deletes the matrix variable of label K. For safety and to
% easily keep track of modifications, set K to the value
% returned by LMIVAR when Xk was created.
%
% Input:
%  LMISYS    array describing the system of LMIs
%  K	     identifier of the variable matrix to be deleted
%            (see LMIVAR)
%
% Output:
%  NEWSYS    updated LMISYS
%
%
% See also  SETMAT, LMIVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function NEWsys=delmvar(LMIsys,k)

if nargin ~= 2,
  error('usage: newsys = delmvar(lmisys,k)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end


[LMI_set,LMI_var,LMI_term,data]=lmiunpck(LMIsys);

if isempty(LMI_var),
   error('No matrix variable description in LMISYS');
end

krk=find(LMI_var(1,:)==k);   % corresponding column in LMI_var
if isempty(krk), error('The label K is out of range'); end
vark=LMI_var(:,krk);
typek=vark(2);
basek=vark(3);
lastk=vark(4);


% form the list of known dec. vars.
if typek<3,
  listdec=basek+1:lastk;
else
  struct=vark(7:6+vark(5)*vark(6));
  listdec=[];
  for n=abs(struct'),
%%% v4 code
%     if n>0 & isempty(find(listdec==n)), listdec=[listdec,n]; end

%%% v5 code
      if n>0 & isempty(listdec), listdec = n;
      elseif n>0 & isempty(find(listdec==n)), listdec=[listdec,n]; end

  end
end

% test if var. to be deleted is independent of others
if ~isempty(find(find((basek >= LMI_var(3,:) & basek < LMI_var(4,:)) | ...
                 (lastk > LMI_var(3,:) & lastk <= LMI_var(4,:)))~=krk)),
   error(sprintf(...
   ['Xk is not independent of the other matrix variables: \n',...
    '                      the deletion could not be performed.']));
end


% delete Xk from LMI_var
%-----------------------

LMI_var(:,krk)=[];


% relabel the decision variables
%--------------------------------
if ~isempty(LMI_var)
  % virtual array of new labels
  vlb=1:basek;
  for i=basek+1:decnbr(LMIsys),
     vlb(i)=i-length(find(listdec <= i));
  end
  vlb=vlb(:);

  ind=find(LMI_var(4,:) > basek);  % vars needing relabeling

  for j=ind,
     var=LMI_var(:,j);
     LMI_var(3,j)=vlb(var(3));
     LMI_var(4,j)=vlb(var(4));

     if var(2)>2,       % type 3
        rs=var(5); cs=var(6);
        struct=var(7:6+rs*cs);
        ind=find(abs(struct)>basek);
        tmp=struct(ind);
        tmp=sign(tmp).*vlb(abs(tmp));
        LMI_var(6+ind,j)=tmp;
     end
  end
end


% delete LMIs involving only this variable
%-----------------------------------------
deldt=[];
vlist=abs(LMI_term(4,:));
llist=sort(abs(LMI_term(1,find(vlist & vlist~=k))));
llist=llist(find(diff([0 llist]) > 0));
% list of LMIs involving other vars
j=0;

for lmilb=LMI_set(1,:),
  j=j+1;
  if ~any(llist==lmilb),
     LMI_set(:,j)=[];
     indt=find(abs(LMI_term(1,:))==lmilb & LMI_term(4,:)~=k);
     deldt=[deldt,[indt;LMI_term(5:6,indt)]];
  end
end
nlmis=size(LMI_set,2);


% update TERM and data arrays
%----------------------------

if ~isempty(LMI_term),
  indt=find(abs(LMI_term(4,:))==k);
  deldt=[deldt,[indt;LMI_term(5:6,indt)]];
end
if isempty(deldt), % no term to be deleted (the var. appeared nowhere)
  NEWsys=lmipck(LMI_set,LMI_var,LMI_term,data); return,
end

LMI_term(:,deldt(1,:))=[]; nterms=size(LMI_term,2);
% update data
delrg=[];
for r=deldt,
  delrg=[delrg , r(2)+1:r(2)+r(3)];
end
data(delrg)=[];


j=0; shft=zeros(1,nterms);
if isempty(LMI_term),
  LMI_set(4:5,:)=zeros(2,nlmis);
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
end



NEWsys=lmipck(LMI_set,LMI_var,LMI_term,data);
