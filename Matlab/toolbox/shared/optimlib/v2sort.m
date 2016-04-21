function v2=v2sort(v1,v2)
%V2SORT Sorts two vectors and then removes missing elements.
%
% This is a helper function.

%   Given two complex vectors v1 and v2, v2 is returned with
%       the nearest elements which are missing from v1 removed.
%     Syntax:  v2=V2SORT(v1,v2) 

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/26 13:27:31 $

lv1=length(v1);
lv2=length(v2);
lv2init=lv2;
v1ones=ones(1,lv1);
v2ones=ones(lv2,1);
diff=abs((v2ones*v1.')-(v2*v1ones));
if lv1>lv2
    temp=min(diff);
    [dum,ind]=sort(-temp);
    for i=1:lv1-lv2
            i2=min([lv2,ind(i)-1]);
            if ind(i)-1<=lv2init & i<lv2init
            v2=[v2((1:i2)');v1(ind(i));v2((i2+1:lv2)')];
        else
            v2=[v2;v1(lv2+1)];
        end
        lv2=lv2+1;
end
else
    temp=min(diff');
    [dum,ind]=sort(-temp);
    v2(ind(1:lv2-lv1))=[];
end

