function bb = creatememberobj(bb,event,order)
% Private.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2003/11/30 23:07:49 $

check = bb.containerobj_isInstantiated; % Check if member is already instantiated

if check(order)==0, % If not yet instantiated, create the appropriate member object
    name = get(event.Source, 'Name');

    all_membinfo_names = fieldnames(bb.containerobj_membinfo)'; % to get data from meminfo, do not use mangledmembname or membname; % instead, use the mangled name for that info structure
    info_str = bb.containerobj_membinfo.(all_membinfo_names{order}); % get information about member
    
    % add 'address' field in info if it does not exist by default -
    % createobj method needs address info
    if isempty(strmatch('address',fieldnames(info_str),'exact'))
        info_str(1).('address') = [bb.containerobj_address(1)+bb.containerobj_memboffset(order),bb.containerobj_address(2)];
    end
    
    try
	    createmember(bb, name, createobj(bb.containerobj_link,info_str) ); % Create object and assign to member
    catch
        disp(lasterr);
        error(['Problem occured while creating member object ' name ]);
    end
    check(order) = 1; % Set IsInstantiated flag to 1
	set(bb,'containerobj_isInstantiated',check); % Save check into 'containerobj_isInstantiated' property
end

% [EOF] creatememberobj.m