function handleStruct = sigbuilder_makemenu(ctxtMenu, labels, calls, tags)
%SIGBUILDER_MAKEMENU Create menu structure.
%  SIGBUILDER_MAKEMENU(CTX, LABELS, CALLS, TAGS) creates a menu structure in
%  context menu CTX according to the order in the string matrix
%  LABELS.  Cascaded menus are indicated by initial '>'
%  characters in the LABELS matrix.  CALLS is a string
%  matrix containing callbacks.  It should have the same
%  number of rows as LABELS.  A row of LABELS that contains
%  any number of '-' characters after the '>' indicators
%  causes a separator line to be placed in the appropriate
%  place. The TAGS string matrix is used to assign the corresponding 
%  'Tag' property of each uimenu item.
%
%  LABELS, CALLS, and TAGS must have the same number of
%  rows.
%
%  H = SIGBUILDER_MAKEMENU( ... ) returns a structure with the tag values
%  as field names
%
%  Example:
%  labels = str2mat( ...
%    '&File', ...
%    '>&New^n', ...
%    '>&Open', ...
%    '>>Open &document^d', ...
%    '>>Open &graph^g', ...
%    '>-------', ...
%    '>&Save^s', ...
%    '&Edit', ...
%    '&View', ...
%    '>&Axis^a', ...
%    '>&Selection region^r' ...
%    );
%       calls = str2mat( ...
%    '', ...
%    'disp(''New'')', ...
%    '', ...
%    'disp(''Open doc'')', ...
%    'disp(''Open graph'')', ...
%    '', ...
%    'disp(''Save'')', ...
%    '', ...
%    '', ...
%    'disp(''View axis'')', ...
%    'disp(''View selection region'')' ...
%    );
%  handleStruct = sigbuilder_makemenu(gcf, labels, calls);

%  Bill Aldrich, modified from makemenu.m by Steve Eddins
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.3 $  $Date: 2002/04/10 18:29:25 $

error(nargchk(4,4,nargin))

num_objects = size(labels,1);
if (num_objects ~= size(calls,1))
  error('LABELS and CALLS must have the same number of rows.');
end
if (nargin == 4)
  if (num_objects ~= size(tags,1))
    error('LABELS and TAGS must have the same number of rows.');
  end
end

remember_handles = ctxtMenu;
handles = [];
current_level = 0;

tagStr = char([]);
separatorFlag=0;
for k = 1:num_objects

  labelStr = labels(k,:);
  % The next two lines are a fast replacement for calling deblank.
  loc = find(labelStr~= ' ' & labelStr~=0);
  labelStr(max(loc)+1:length(labelStr)) = [];
  if (nargin == 4)
    tagStr = tags(k,:);
    % The next two lines are a fast replacement for calling deblank.
    loc = find(tagStr~= ' ' & tagStr~=0);
    tagStr(max(loc)+1:length(tagStr)) = [];
  end
  
  % Determine which object to attach to by checking the level.
  loc = find(labelStr ~= '>');
  if (isempty(loc))
    error(str2mat('Label strings must have at least one character', ...
                  'that''s not a ">"'));
  end
  new_level = loc(1) - 1;
  labelStr = labelStr(loc(1):length(labelStr));
  if (new_level > current_level)
    remember_handles = [remember_handles handles(length(handles))];
  elseif (new_level < current_level)
    N = length(remember_handles);
    remember_handles(N-(current_level-new_level)+1:N) = [];
  end
  current_level = new_level;

  if (labelStr(1) == '-')
    separatorFlag = 1;
  else
    if (separatorFlag)
      separator = 'on';
      separatorFlag = 0;
    else
      separator = 'off';
    end
  
    % Preprocess the label.
    [labelStr, acc] = menulabel(labelStr);
    if (isempty(labelStr))
      error('Empty label field.');
    end
    
    % Note:  much of the overhead in this function is spent in calls
    % to deblank.  So we're going to trade off speed for figure memory
    % overhead and not deblank the callback string.
    
    h = uimenu(remember_handles(length(remember_handles)), ...
        'Label', xlate(labelStr), 'Accelerator', acc, 'Callback', calls(k,:), ...
        'Separator',separator,...
        'Tag', tagStr);
    
    if isempty(handles)
        handleStruct = struct(tagStr,h);
    else
        handleStruct = setfield(handleStruct,tagStr,h);
    end

    handles = [handles ; h];

  end

end

