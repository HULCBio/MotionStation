function pim = allocpim(rcdata,ldpim)
% function pim = allocpim(rcdata,ldpim)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

% cases:
%   rcdata nx2, nargin = 1  -->  ldpim = largenum, indices = 1:n
%   rcdata nx2, nargin = 2  -->  use ldpim, indices = 1:n
%   rcdata nx3, nargin = 1  -->  ldpim = largenum, indices = rcdata(:,3)
%   rcdata nx3, nargin = 2  -->  use ldpim, indices = rcdata(:,3)
%   rcdata nx4, nargin = 1  -->  ldpim = max(rcdata(:,3)), indices = convert(rcdata(:,[3 4]))
%   rcdata nx4, nargin = 2  -->  use ldpim, indices = convert(rcdata(:,[3 4]))

    pim = [];
    largenum = 123456;

    if nargin == 0
        disp('usage: pim = allocpim(rowcoldata)');
        return
    end

    if isempty(rcdata)
       error('Row/Column data is empty.');
       return
    end
    if any(any(floor(rcdata)~=ceil(rcdata))) | any(any(rcdata<0))
        error('Row/Column Data must be nonnegative integers');
        return
    end
    if nargin == 2
        if floor(ldpim)~=ceil(ldpim) | ldpim<0 | ldpim>=largenum
            error('Leading dimension must be nonnegative');
            return
        end
    end

    [num,dum] = size(rcdata);
    if dum==2 & nargin == 1
        ldpim = largenum;
        len = 3*num + 3 + sum(rcdata(:,1).*rcdata(:,2));
        pim = zeros(len,1);
        pim(1) = ldpim;
        pim(2) = inf;
        pim(3) = num;
        pim(4:num+3) = (1:num)';
        pim(num+4:2*num+3) = rcdata(:,1);
        pim(2*num+4:3*num+3) = rcdata(:,2);
    elseif dum==2 & nargin == 2
        len = 3*num + 3 + sum(rcdata(:,1).*rcdata(:,2));
        pim = zeros(len,1);
        pim(1) = ldpim;
        pim(2) = inf;
        pim(3) = num;
        pim(4:num+3) = (1:num)';
        pim(num+4:2*num+3) = rcdata(:,1);
        pim(2*num+4:3*num+3) = rcdata(:,2);
    elseif dum==3 & nargin == 1
        ldpim = largenum;
        if any(floor(rcdata(:,3))~=ceil(rcdata(:,3))) | any(rcdata(:,3)<1)
            error('Indices must be positive integers');
            return
        end
        len = 3*num + 3 + sum(rcdata(:,1).*rcdata(:,2));
        pim = zeros(len,1);
        pim(1) = ldpim;
        pim(2) = inf;
        pim(3) = num;
        pim(4:num+3) = rcdata(:,3);
        pim(num+4:2*num+3) = rcdata(:,1);
        pim(2*num+4:3*num+3) = rcdata(:,2);
    elseif dum==3 & nargin == 2
        if any(floor(rcdata(:,3))~=ceil(rcdata(:,3))) | any(rcdata(:,3)<1)
            error('Indices must be positive integers');
            return
        end
        len = 3*num + 3 + sum(rcdata(:,1).*rcdata(:,2));
        pim = zeros(len,1);
        pim(1) = ldpim;
        pim(2) = inf;
        pim(3) = num;
        pim(4:num+3) = rcdata(:,3);
        pim(num+4:2*num+3) = rcdata(:,1);
        pim(2*num+4:3*num+3) = rcdata(:,2);
    elseif dum==4 & nargin == 1
        if any(floor(rcdata(:,3))~=ceil(rcdata(:,3))) | any(rcdata(:,3)<1) | ...
                any(floor(rcdata(:,4))~=ceil(rcdata(:,4))) | any(rcdata(:,4)<1)
            error('Indices must be positive integers');
            return
        end
        ldpim = max(rcdata(:,3));
        if ldpim>=largenum
            error('Leading dimension is too big');
            return
        end
        len = 3*num + 3 + sum(rcdata(:,1).*rcdata(:,2));
        pim = zeros(len,1);
        pim(1) = ldpim;
        pim(2) = inf;
        pim(3) = num;
        pim(4:num+3) = rcdata(:,3) + ldpim*(rcdata(:,4)-1);
        pim(num+4:2*num+3) = rcdata(:,1);
        pim(2*num+4:3*num+3) = rcdata(:,2);
    elseif dum==4 & nargin == 2
        if any(floor(rcdata(:,3))~=ceil(rcdata(:,3))) | any(rcdata(:,3)<1) | ...
                any(floor(rcdata(:,4))~=ceil(rcdata(:,4))) | any(rcdata(:,4)<1)
            error('Indices must be positive integers');
            return
        end
        if any(rcdata(:,3)>ldpim)
            error('Leading dimension is not large enough');
            return
        end
        len = 3*num + 3 + sum(rcdata(:,1).*rcdata(:,2));
        pim = zeros(len,1);
        pim(1) = ldpim;
        pim(2) = inf;
        pim(3) = num;
        pim(4:num+3) = rcdata(:,3) + ldpim*(rcdata(:,4)-1);
        pim(num+4:2*num+3) = rcdata(:,1);
        pim(2*num+4:3*num+3) = rcdata(:,2);
    end