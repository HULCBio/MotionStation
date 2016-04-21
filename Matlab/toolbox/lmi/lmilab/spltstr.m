% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [s1,s2,s3,s4,s5,fail]=spltstr(hdl,s)

fail=0;
ind=find(s(:,1)=='*' & s(:,2)=='%');

if length(ind)~=4,
  parslerr(hdl,'This string is not an LMI system description');
  s1=[]; s2=[]; s3=[]; s4=[]; s5=[]; fail=1; return
end

cs=size(s,2);

s1=['  ' dblnk(s(1:ind(1)-1,:))];
s2=s(ind(1)+1:ind(2)-1,1:min(20,cs));
s3=s(ind(2)+1:ind(3)-1,1:min(20,cs));
s4=s(ind(3)+1:ind(4)-1,:);
s5=s(ind(4)+1:size(s,1),:);
