function prevState = cmd_window_buffering(newstate)
%CMD_WINDOW_BUFFERING - Turn command window buffering 'on' or 'off' on the PC
%
%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.7 $

  if isunix
    error('Not supported on unix');
  end

  text = evalc('system_dependent(7);');

  if ~isempty(findstr(text,'buffering disabled'))
    prevState = 'on';
  else
    prevState = 'off';
  end

  switch newstate
   case 'on'
    if ~strcmp(prevState,'off')
      evalc('system_dependent(7);');
    end
   case 'off'
    if ~strcmp(prevState,'on')
      evalc('system_dependent(7);');
    end
   otherwise
    error('Illegal newstate');
  end

%endfunction cmd_window_buffering
