function ert_callback_handler (varargin)
% ERT_CALLBACK_HANDLER - RTW GUI Embedded Real-Time callback handler
%
%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.8 $

if (nargin == 0)
  dialogFig = get (gcbo, 'Parent');
else
  dialogFig = varargin{1};
end

mfile = findobj (dialogFig, 'Tag', 'MAT-file logging_CheckboxTag');
int_code = findobj (dialogFig, 'Tag', 'Integer code only_CheckboxTag');
if (isequal(get(mfile,'Value'),0))
  % If mfile is off, we don't care what int_code's value is.
  return;
else
  % Else, mfile is on.
  if (gcbo == mfile)
    % If MAT file logging was the one who called this function, that
    % means it was just turned on, which means we must make sure that
    % integer code generation is off.
    set (int_code, 'Value', 0);
  else
    % It must be integer code generation that called this function, which
    % means that it will now be on and we must shut off MAT file logging.
    set (mfile, 'Value', 0);
  end
end
  
  

