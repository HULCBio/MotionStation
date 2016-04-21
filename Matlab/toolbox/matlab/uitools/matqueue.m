function y = matqueue(p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18)
%MATQUEUE Obsolete function.
%   MATQUEUE function is obsolete and may be removed from future versions.
%
%   See also SAVE, LOAD, PERSISTENT

warning('UITools:ObsoleteFunction:matqueue', 'MATQueue function is obsolete.');

%MATQUEUE Creates and manipulates a figure-based matrix queue.
%   FIG = MATQUEUE('create');
%   Create a queue figure and return its number.
%
%   FIG = MATQUEUE('find');
%   Searches the root window's children to find the queue
%   figure.  Returns 0 if no queue exists.
%
%   MATQUEUE('put', X1, X2, ..., X18);
%   Insert up to 18 matrices into the queue.  Create the
%   queue if none exists.
%   
%   X = MATQUEUE('get');
%   Get a matrix out the queue.  Return [] if the queue is
%   empty.
%
%   NUM_ITEMS = MATQUEUE('length');
%   Return the number of matrices in the queue.  Return -1 if
%   no buffer exists. 
%
%   MATQUEUE('clear')
%   Empty the queue.
%
%   MATQUEUE('close')
%   Close the queue figure.
%
%   This function is OBSOLETE and may be removed in future versions.

%   Steven L. Eddins 1-14-94
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.41.4.1 $  $Date: 2002/10/24 02:13:36 $

buffer_name = 'FIFO Buffer';

if (nargin < 1)
  action = 'create';
else
  action = lower(p0);
end

if (strcmp(action, 'create'))
  
  %==================================================================
  % Create a new queue.
  %
  % matqueue('create');
  %==================================================================

  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  oldFig = findobj(allchild(0), 'flat', 'Visible', 'on');

  buffer_fig = matqueue('find');
  if (buffer_fig ~= 0) 
    % Buffer already exists; do nothing
    return;
  end

  buffer_fig = figure('Name', buffer_name, ...
      'Visible', 'off',...
      'HandleVisibility', 'callback', ...
      'IntegerHandle', 'off', ...
      'NumberTitle', 'off', ...
      'Tag', buffer_name);
  if (~isempty(oldFig))
    figure(oldFig(1));
  end
  
  queue_holder = uicontrol(buffer_fig, 'Style', 'text', ...
      'Visible', 'off', 'Tag', 'QueueHolder');

  y = buffer_fig;

  return;
  
elseif (strcmp(action, 'find'))
  
  %==================================================================
  % Find the queue figure.  If no queue figure exists, return 0.
  %
  % matqueue('find');
  %==================================================================
  
  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  % Search the root's children for a figure with the right name
  buffer_number = findobj(allchild(0), 'flat', 'Tag', buffer_name);
  if (isempty(buffer_number))
    y = 0;
  else
    y = buffer_number(1);
  end
  
  return;
  
elseif (strcmp(action, 'put'))
  
  %==================================================================
  % Put matrices into the queue.  Queue figure is created if none
  % exists.
  %
  % matqueue('put', X1, X2, ..., X18);
  %==================================================================
  
  error(nargchk(2,19,nargin));
  error(nargchk(0,0,nargout));
  
  buffer_fig = matqueue('find');
  if (buffer_fig == 0)
    buffer_fig = matqueue('create');
  end
  
  queue_holder = findobj(get(buffer_fig, 'Children'), 'flat', 'Tag', 'QueueHolder');
  if (isempty(queue_holder))
    error('Corrupted matrix queue.');
  end
  
  handles = get(queue_holder, 'UserData');
  
  num_inputs = nargin-1;
  new_handles = zeros(1, num_inputs);
  for i = 1:num_inputs
    arg_name = ['p', num2str(i)];
    try_string = ['new_handles(num_inputs+1-i)=uicontrol(buffer_fig,', ...
        ' ''Style'',''text'',''Visible'','...
        ' ''off'',''UserData'',', arg_name, ');'];
    eval(try_string);
  end
  
  set(queue_holder, 'UserData', [new_handles handles]);
  
  return;
  
elseif (strcmp(action, 'get'))
  
  %==================================================================
  % Return earliest matrix item in the queue.  Errors out if there's
  % no queue.  Returns empty matrix if queue is empty.
  %
  % X = matqueue('get');
  %==================================================================
  
  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));

  buffer_fig = matqueue('find');
  if (buffer_fig == 0)
    % No buffer; return empty matrix.
    y = [];
    return;
  end

  queue_holder = findobj(get(buffer_fig, 'Children'), 'flat', 'Tag', 'QueueHolder');
  if (isempty(queue_holder))
    error('Corrupted matrix queue.');
  end
  
  handles = get(queue_holder, 'UserData');
  N = length(handles);
  if (N > 0)
    y = get(handles(N), 'UserData');
    delete(handles(N));
    handles(N) = [];
    set(queue_holder, 'UserData', handles);
  else
    % Nothing in the buffer; return empty matrix
    y = [];
  end
  
  return;
  
elseif (strcmp(action, 'length'))
  
  %==================================================================
  % Returns the length of the queue.  Returns -1 if no queue 
  % figure exists.
  %
  % num_items = matqueue('length');
  %==================================================================
  
  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  buffer_fig = matqueue('find');
  if (buffer_fig == 0)
    % No buffer!  Return 0.
    y = 0;
    return;
  end
  
  queue_holder = findobj(get(buffer_fig, 'Children'), 'flat', 'Tag', 'QueueHolder');
  if (isempty(queue_holder))
    error('Corrupted matrix queue.');
  end
  
  y = length(get(queue_holder, 'UserData'));
  
  return;

elseif (strcmp(action, 'clear'))
  
  %==================================================================
  % Clear the queue.
  %
  % matqueue('clear');
  %==================================================================
  
  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  buffer_fig = matqueue('find');
  if (buffer_fig == 0)
    % No buffer; nothing to do.
    return;
  end
  
  queue_holder = findobj(get(buffer_fig, 'Children'), 'flat', 'Tag', 'QueueHolder');
  if (~isempty(queue_holder))
    delete(queue_holder);
  end
  
  queue_holder = uicontrol(buffer_fig, 'Style', 'text', ...
      'Visible', 'off', 'Tag', 'QueueHolder');
  
  return;
  
elseif (strcmp(action, 'close'))
  
  %==================================================================
  % Close the queue figure.
  %
  % matqueue('close');
  %==================================================================
  
  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  buffer_fig = matqueue('find');
  if (buffer_fig ~= 0)
    close(buffer_fig);
  end
  
  return;
  
else
  
  error('Unknown action.');
  
end
