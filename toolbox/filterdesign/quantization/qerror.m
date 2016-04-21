function msg = qerror(msg)
%QERROR Clean up errors.
%   QERROR(msg) removes trailing carriage returns, blanks, and any line
%   containing 'Error using ==>' before calling ERROR.  This is done to clean
%   up the backtraces in the error messages.
%
%   If "warning backtrace", then do not strip out the error backtraces
%   either. 

%   Thomas A. Bryan, 23 September 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/14 15:36:23 $

% Remove trailing blanks and carriage returns.
wrec = warning('query', 'backtrace');
if strcmpi(wrec.state, 'on')
  % Leave backtrace messages in.
  return
end

% Strip backtrace messages.
if ~isempty(msg)
  CR = sprintf('\n');
  m = sprintf('Error using ==>');
  i = findstr(msg,CR);
  [c{1:length(i)+1,1}] = deal('');
  if isempty(i)
    c{1} = msg;
  else
    % Cut into rows
    c{1} = msg(1:i(1));
    for k=2:length(i)
      c{k} = msg(i(k-1)+1:i(k));
    end
  end
  i = strmatch(m,c);
  if ~isempty(i), [c{i}] = deal(''); end
  msg = [c{:}];
  i = find(msg ~= ' ' & msg ~= 0 & msg ~= CR);
  if ~isempty(i)
    msg = msg(1:max(i));
  end
end

