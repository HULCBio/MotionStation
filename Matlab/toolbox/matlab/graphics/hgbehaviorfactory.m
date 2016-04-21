function [b] = hgbehaviorfactory(behavior_name)
% This internal helper function may be removed in a future release.

%HGBEHAVIORFACTORY Convenience for creating behavior objects
%   
%   HGGETBEHAVIOR
%   With no arguments, a list of all registered behavior
%   objects is generated to the command window.
%
%   BH = HGBEHAVIORFACTORY(NAME)
%   Specify NAME (string or cell array of strings) to create
%   behavior objects.
%
%   Example 1:
%   bh = hgbehaviorfactory('Zoom');
%
%   Example 2:
%   h = line;
%   bh = hgbehaviorfactory({'Zoom','DataCursor','Rotate3d'});
%   set(h,'Behavior',bh);
%
%   See also hgaddbehavior, hggetbehavior.

% Copyright 2003-2004 The MathWorks, Inc.

if nargin==0
    % Pretty print output
    info = localGetBehaviorInfo;
    localPrettyPrint(info);
else
    b = localCreate(behavior_name);
end

%---------------------------------------------------%
function [ret_h] = localCreate(behavior_name)

ret_h = handle([]);
dat = localGetBehaviorInfo;
for n = 1:length(dat)
     info = dat{n};
     s = strcmpi(behavior_name,info.name);
     if any(s)
         ind = find(s==true);
         behavior_name(ind) = [];
         ret_h(end+1) = feval(info.constructor);
     end
end

%---------------------------------------------------%
function localPrettyPrint(behaviorinfo)
% Pretty prints to command window
% in a similar manner as the PATH command.

% Header
disp(' ');
disp(sprintf('\tBehavior Object Name         Target Handle'))     
disp(sprintf('\t--------------------------------------------'))

info = {};
for n = 1:length(behaviorinfo)
    str1 = behaviorinfo{n}.name;
    str2 = behaviorinfo{n}.targetdescription;

    % cheezy string formatting
    padl = 30-length(str1);
    p = [];
    if padl>0
      p = zeros(1,padl); p(:) = '.';
    end
    info{n} = ['''',str1,'''',p,str2];
end

% Display items
ch= strvcat(info);
tabspace = ones(size(ch,1),1);
tabspace(:) = sprintf('\t');
s = [tabspace,ch];
disp(s)

% Footer
disp(sprintf('\n'))

%---------------------------------------------------%
function [behaviorinfo] = localGetBehaviorInfo
% Loads info for registered behavior objects

behaviorinfo = {};

info = [];
info.name = 'Plotedit';
info.targetdescription = 'Any Graphics Object';
info.constructor = 'graphics.ploteditbehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Print';
info.targetdescription = 'Any Graphics Object';
info.constructor = 'graphics.printbehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Zoom';
info.targetdescription = 'Axes';
info.constructor = 'graphics.zoombehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Pan';
info.targetdescription = 'Axes';
info.constructor = 'graphics.panbehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Rotate3d';
info.targetdescription = 'Axes';
info.constructor = 'graphics.rotate3dbehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'DataCursor';
info.targetdescription = 'Axes and Axes Children';
info.constructor = 'graphics.datacursorbehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'MCodeGeneration';
info.targetdescription = 'Axes and Axes Children';
info.constructor = 'graphics.mcodegenbehavior';
behaviorinfo{end+1} = info;

