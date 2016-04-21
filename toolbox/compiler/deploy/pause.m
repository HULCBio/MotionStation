function [varargout] = pause(varargin)
  warnStatus = warning('query', 'MCR:READLINE:zerolengthprompt');
  warning('off', 'MCR:READLINE:zerolengthprompt');
  if( nargin == 0 )
    if( nargout > 0 )
      varargout{1:nargout} = input('');
    else
      input('');
    end
  else
    if nargout == 0
      builtin('pause', varargin{:});
    else
      [varargout{1:nargout}] = builtin('pause', varargin{:});
    end
  end
  warning(warnStatus);
    