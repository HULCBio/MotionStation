% function item = xpii(pim,i1,i2)
%
%    XPII: eXtract Packed Indexed Item

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function item = xpii(pim,i1,i2)

 if nargin < 2
   disp('usage: item = xpii(pim,i)');
   return
 end

 if nargin==2
    if floor(i1)~=ceil(i1) | i1<1
        error('Index must be a positive integer');
        return
    end
    i2 = 1;
 elseif nargin == 3
    if any(floor([i1;i2])~=ceil([i1;i2])) | i1<1 | i2<1
        error('Indices must be positive integers');
        return
    end
 end

if isempty(pim)
    item = [];
else
    ldpim = pim(1);
    i = i1 + ldpim*(i2-1);
    num = pim(3);
    repindex = pim(4:3+num);
    rowd = pim(4+1*num:3+2*num);
    cold = pim(4+2*num:3+3*num);
    lenv = abs(rowd).*cold;
    %   datavec = pim(4+3*num:length(pim));  DONT ALLOCATE THIS - ITs HUGE
    a = find(repindex == i);
    if isempty(a)
        item = [];
    else
        if rowd(a) >= 0
            sp = sum(lenv(1:a-1)) + 1;
            %  item = reshape(datavec(sp:sp+lenv(a)-1),rowd(a),cold(a));
            item = reshape(pim(3+3*num+sp:2+3*num+sp+lenv(a)),rowd(a),cold(a));
        else
            sp = sum(lenv(1:a-1)) + 1;
            %  item = setstr(reshape(datavec(sp:sp+lenv(a)-1),-rowd(a),cold(a)));
            item = setstr(reshape(pim(3+3*num+sp:2+3*num+sp+lenv(a)),-rowd(a),cold(a)));
        end
    end
end