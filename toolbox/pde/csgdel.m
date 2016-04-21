function [dl1,bt1]=csgdel(dl,bt,bl)
%CSGDEL Delete boundaries between minimal regions.
%
%       [DL1,BT1]=CSGDEL(DL,BT,BL) deletes the border segments in the list
%       BL. If the consistency of the Decomposed Geometry matrix is not
%       preserved by the elements in the list BL, additional border
%       segments will be deleted.
%
%       DL and DL1 are Decomposed Geometry matrices.  See DECSG for details.
%
%       BT and BT1 are Boolean tables. See DECSG for details.
%
%       [DL1,BT1]=CSGDEL(DL,BT) deletes all border segments.
%
%       See also: DECSG

%       L. Langemyr 1995-02-01.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/10/21 12:26:05 $

if nargin<2
  error('PDE:csgdel:nargin', 'Not enough input arguments.');
end

if nargin<3
  bl=find([dl(6,:)~=0 & dl(7,:)~=0]);
end

dl1=dl;
bt1=bt;

if isempty(bl)
  return
end

ns=max(max(dl(6,:)),max(dl(7,:)));

% Check that outer boundaries are not removed.
i=find(dl(6,bl)==0|dl(7,bl)==0);
if ~isempty(i)
  error('PDE:csgdel:CannotRemoveOutBnd', 'Cannot remove outer boundary.');
end

% Add internal boundaries around the same subdomain border

nl=[];
for i=1:length(bl)
  k=find((dl(6,:)==dl(6,bl(i)) & dl(7,:)==dl(7,bl(i))) | ...
         (dl(6,:)==dl(7,bl(i)) & dl(7,:)==dl(6,bl(i))));
  nl=[nl k];
end

bl=sort(nl);
bl=bl(logical([1 sign(diff(bl))]));

cm=sparse(dl(6,bl),dl(7,bl),1,ns,ns);
cm=cm+cm';
tm=sparse([],[],[],ns,ns);
while any(any(cm~=tm))
  tm=cm;
  cm=sign(cm+cm*cm);
end

eq=[]; used=~full(sign(max(cm))); j=1; i=find(~used);

while ~isempty(i)
  i=find(cm(i(1),:))';
  used(i)=ones(1,length(i));
  eq(1:length(i)+1,j)=[length(i);i];
  i=find(~used);
  j=j+1;
end

for i=1:size(eq,2)
  for j=3:eq(1,i)+1
    k=find(dl1(6,:)==eq(j,i));
    dl1(6,k)=eq(2,i)*ones(1,length(k));
    k=find(dl1(7,:)==eq(j,i));
    dl1(7,k)=eq(2,i)*ones(1,length(k));
  end
end

ind=[dl1(6,:),dl1(7,:)];                % pack indices
ind=sort(ind);
ind=ind(logical([1 sign(diff(ind))]));
ind(~ind)=[];
bt1=bt(ind,:);                          % -- of boolean table
j=1;                                    % -- in sml and smr
for i=ind
  k=find(dl1(6,:)==i);
  dl1(6,k)=j*ones(1,length(k));
  k=find(dl1(7,:)==i);
  dl1(7,k)=j*ones(1,length(k));
  j=j+1;
end

dl1(:,bl)=[];

