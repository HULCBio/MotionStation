function CacheOriginalData(h)
%   CACHEORIGINALDATA is the method caches original data before starting 
%   make_rtw process.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/23 16:26:58 $


%Cache the original dirty flag  
h.OrigDirtyFlag = get_param(h.ModelHandle,'Dirty');

% cache the original start time
h.OrigStartTime = get_param(h.ModelHandle, 'StartTime');

% cache the original lock and dirty flags
h.OrigLockFlag  = get_param(h.ModelHandle,'Lock');
if strcmp(h.OrigLockFlag, 'on'),
    % need to unlock the model so that the set_params in the code below will
    % work
    set_param(h.ModelHandle,'Lock','off');
end

%
%  Should not cache following values.
%
%Cache the original RTW options  
%  h.OrigRTWOptions  = get_param(h.ModelHandle,'RTWOptions');
%Cache the original RTW InlineParameters setting
%  h.OrigRTWInlineParameters  = get_param(h.ModelHandle,'RTWInlineParameters');
