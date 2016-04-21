function [ret_h] = hggetbehavior(h,behavior_name,flag)
% This internal helper function may be removed in a future release.

%HGGETBEHAVIOR Convenience for getting behavior objects
%
%   HGGETBEHAVIOR 
%   With no arguments, a list of all registered behavior
%   objects is generated to the command window.
%
%   BH = HGGETBEHAVIOR(H)
%   Identical to get(H,'Behavior'), this syntax returns all 
%   behavior objects currently associated with handle H.
%
%   BH = HGGETBEHAVIOR(H,NAME) 
%   This syntax will return a behavior object of the given
%   NAME (NAME can be a string or cell array of strings). 
%   Behavior objects are lazy loaded (created on the fly) 
%   by this function. 
%
%   BH = HGGETBEHAVIOR(H,NAME,'-peek') 
%   The '-peek' flag by-passes lazy loading so that no behavior
%   objects are implicitly created. This syntax may return 
%   empty output if no behavior objects of the given type
%   are currently associted with this object.
%
%   Example 1:
%   % Prevent zooming on axes
%   ax = axes;
%   bh = hggetbehavior(ax,'Zoom');
%   set(bh,'Enable',false); 
%   zoom on; % zoom should not work on this axes
%
%
%   Example 2: (place in m-file)
%   % Customize data cursor string function for a line
%   h = line;
%   bh = hggetbehavior(h,'DataCursor');
%   set(bh,'UpdateFcn',@myupdatefcn); 
%   
%   function [str] = myupdatefcn(hSource,hEvent)
%   % See DATACURSORMODE for full description of
%   % input arguments.
%   str = 'my string';
%
%   See also hgbehaviorfactory.

% Copyright 2003 The MathWorks, Inc.


if nargin==0
    % pretty print list of available behavior objects
    hgbehaviorfactory
    return;
end

ret_h = [];
h = handle(h);

bb = get(h,'Behavior');
if isstruct(bb)
    set(h,'Behavior',[]);
end

if length(h)>1
  error('MATLAB:GRAPHICS:HGGETBEHAVIOR','Scalar handle input required');
end

if nargin==1
    ret_h = get(h,'Behavior');
elseif nargin==3
    if strcmp(flag,'-peek')
        ret_h = localPeek(h,behavior_name);     
    end
elseif nargin==2
    ret_h = localGet(h,behavior_name);
end

%-------------------------------------------%
function [ret_h] = localGet(h,behavior_name)
% ToDo: Optimize to avoid excessive looping

bb = get(h,'Behavior');
ret_h = handle([]);

if isstr(behavior_name)
    behavior_name = {behavior_name};
end

for n = 1:length(behavior_name)
     bn = behavior_name{n};
     b = localPeek(h,bn);
     if isempty(b)
        b = hgbehaviorfactory(bn);
        if ~isempty(b) 
            if ~dosupport(b,h)
                error('MATLAB:GRAPHICS:HGGETBEHAVIOR',...
                'Behavior object does not support this handle type.')  
            end
            set(h,'Behavior',[bb,b]);
            ret_h(end+1) = b;
        end
     else
       ret_h(end+1) = b;
     end
end

%-------------------------------------------%
function [ret_h] = localPeek(h,behavior_name)
% Loop through available behavior objects

ret_h = handle([]);
bb = get(h,'Behavior');

if isstruct(bb)
    set(h,'Behavior',[]);
else
    for n = 1:length(bb)
       b = bb(n);
       if ishandle(b)
           s = strcmpi(behavior_name,get(b,'Name'));
           if any(s)
               ind = find(s==true);
               behavior_name(ind) = [];
               ret_h(end+1) = b;
           end
       end
    end    
end