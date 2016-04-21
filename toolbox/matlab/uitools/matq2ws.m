%MATQ2WS Helper script for matqdlg.
%MATQ2WS Obsolete function.
%   MATQ2WS function is obsolete and may be removed from future versions.
%
%   See also SAVE, LOAD, PERSISTENT

warning('UITools:ObsoleteFunction:matq2ws', 'MATQ2WS function is obsolete.');

%  MATQ2WS gets the user-entered comma-delimited string,
%  parses it, and then tries to put the queue contents one
%  at a time into the resulting variable names.  For
%  recoverable errors, the prompt is reset and the user can
%  try again.  Recoverable errors include empty input
%  string, string containing "#", too few variable names,
%  and too many variable names.  If the user types something
%  that cannot be a workspace variable name, that's a
%  nonrecoverable error.  The queue is cleared and made
%  invisible, and an error message is printed to the command
%  window. 
%
%  This function is OBSOLETE and may be removed in future versions.

%  Steven L. Eddins, January 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.20.4.1 $  $Date: 2002/10/24 02:13:33 $

% Variable names (these need to be cleared before returning):
% var_string_ err_string_ new_prompt_ pound_ N_
% fatal_error_flag_ i_ expr_ try_string_ catch_string_ error_message_ 


var_string_ = get(findobj(gcf,'Tag','Entry'), 'String');
[var_string_, err_string_] = matqparse(var_string_);
if (~isempty(err_string_))
  errordlg(str2mat('Could not parse your expression.', err_string_), ...
      'Workspace Transfer Error', 'on');
  clear var_string_ err_string_ new_prompt_ ...
      pound_ N_ fatal_error_flag_ i_ expr_ try_string_ catch_string_ ...
      error_message_
  return;
end
N_ = size(var_string_, 1);
if (N_ < matqueue('length'))
  errordlg(str2mat('You did not enter enough variable names.', ...
      'Please try again.'), 'Workspace Transfer Error', 'on');
  clear var_string_ err_string_ new_prompt_ ...
      pound_ N_ fatal_error_flag_ i_ expr_ try_string_ catch_string_ ...
      error_message_
  return;
elseif (N_ > matqueue('length'))
  errordlg(str2mat('You entered too many variable names.', ...
      'Please try again.'), 'Workspace Transfer Error', 'on');
  clear var_string_ err_string_ new_prompt_ ...
      pound_ N_ fatal_error_flag_ i_ expr_ try_string_ catch_string_ ...
      error_message_
  return;
end
fatal_error_flag_ = 0;
for i_ = 1:N_
  expr_ = deblank(var_string_(i_, :));
  try
      eval( [expr_ '=matqueue(''get'');'] );
  catch
      fatal_error_flag_ = 1;
  end

  if (fatal_error_flag_)
    errordlg(str2mat(sprintf('Error using "%s" as a workspace variable.', ...
  expr_), 'You will need to start over.'), ...
  'Workspace Transfer Error', 'on');
    set(matqdlg('find'), 'Visible', 'off');
    if (~isempty(get(matqdlg('find'),'UserData')))
      if (any(get(0,'Children') == get(matqdlg('find'),'UserData')))
  figure(get(matqdlg('find'),'UserData'));
      end
    end
    matqueue('clear');
    clear var_string_ err_string_ new_prompt_ ...
  pound_ N_ fatal_error_flag_ i_ expr_ try_string_ catch_string_ ...
  error_message_
    return;
  end
end
set(matqdlg('find'), 'Visible', 'off');
if (~isempty(get(matqdlg('find'),'UserData')))
  if (any(get(0,'Children') == get(matqdlg('find'),'UserData')))
    figure(get(matqdlg('find'),'UserData'));
  end
end

try
    char(get(get(matqdlg('find'),'CurrentObject'),'UserData'));
catch
    disp('Error evaluating button callback.')
end
close(matqdlg('find'));
clear var_string_ err_string_ new_prompt_ ...
    pound_ N_ fatal_error_flag_ i_ expr_ try_string_ catch_string_ error_message_ 
