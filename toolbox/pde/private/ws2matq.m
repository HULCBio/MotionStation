%WS2MATQ Helper script for MATQDLG.

%  WS2MATQ gets the user-entered comma-delimited string,
%  parses it, evals the expressions one a time, putting the
%  results into the queue.  If an error is encountered,
%  WS2MATQ clears the queue and calls it again with an error
%  message prompt. 

%  Steven L. Eddins, January 1994
%  Copyright 1984-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2003/11/24 23:24:19 $

% Variable list (these variables need to be cleared out of the workspace at
% the end):
% var_string_   err_string_  new_prompt_   pound_
% N_   error_flag_   error_message_   expr_   try_string_
% catch_string_   tmp_   i_

var_string_ = get(findobj(gcf,'Tag','Entry'), 'String');
[var_string_, err_string_] = matqparse(var_string_);
if (~isempty(err_string_))
  errordlg(str2mat('Could not parse your expression.', err_string_, ...
      'Please try again.'), 'Workspace Transfer Error', 'on');
  matqueue('clear');
  clear var_string_ err_string_ new_prompt_ pound_ ...
      N_ error_flag_ error_message_ expr_ try_string_ catch_string_ ...
      tmp_ i_
  return;
end
N_ = size(var_string_, 1);
error_flag_ = 0;
error_message_ = [];
for i_ = 1:N_
  expr_ = var_string_(i_, :);
  try
      eval(['tmp_=', expr_, ';']);
  catch
      error_message_= str2mat(sprintf('Error evaluating "%s".',expr_), ...
                              'Try enclosing expressions in brackets.');
  end
  if (isempty(error_message_))
    matqueue('put', tmp_);
  else 
    break;
  end
end
if (~ isempty(error_message_))
  errordlg(error_message_, 'Workspace Transfer Error', 'on');
  matqueue('clear');
  clear var_string_ err_string_ new_prompt_ pound_ ...
      N_ error_flag_ error_message_ expr_ try_string_ catch_string_ ...
      tmp_ i_
  return;
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
    disp('Error evaluating button callback.');
end

close(matqdlg('find'));
clear var_string_ err_string_ new_prompt_ pound_ ...
    N_ error_flag_ error_message_ expr_ try_string_ catch_string_ ...
    tmp_ i_ prev_fig_
