function [v2,pind]=vsort(v1,v2,sp)
%VSORT Matches two vectors.  Used in RLOCUS.
%   VS2 = VSORT(V1,V2) matches two complex vectors 
%   V1 and V2, returning VS2 with consists of the elements 
%   of V2 sorted so that they correspond to the elements 
%   in V1 in a least squares sense.

%       [v2,pind]=VSORT(v1,v2,sp) 
%       sp is used to test a quick sort method and is equal to
%       sp=sum([1:length(indr)].^2); pind=1 is returned if
%       a slow sort method has to be applied.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:53:20 $

pind=0;
if nargin < 3, sp = sum([1:length(v1)].^2); end
% Quick Sort 
p=length(v2);
vones=ones(p,1);
[dum,indr1]=min(abs(vones*v2.'-v1*vones'));
indr(indr1)=[1:p];

% Long (accurate) sort
if (indr*indr' ~= sp) 
    [dum,jnx]=sort(abs(v2));
    pind=1;
    for j=jnx' 
        [dum,inx]=min(abs(v2(j)-v1));
        indr(inx)=j;
        v1(inx)=1e30;
    end

end
v2=v2(indr');

% end vsort
