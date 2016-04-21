function debug(hThis,str,varargin)
% utility for debugging UDD event callbacks 

% Copyright 2003 The MathWorks, Inc.


if ~isa(hThis,'graphics.cursorbar')
    return;
end

if ~hThis.Debug
    return;
end

if length(varargin)>0
    hEvent = varargin{1};
    if isa(hEvent,'handle.EventData')
       hSrc = hEvent.Source;
       if isa(hSrc,'schema.prop')
          disp(sprintf('%s: %s',str,hSrc.Name))
          return;
       elseif ischar(hEvent)
           disp(sprintf('%s : %s',str,hEvent));
           return
       end
    elseif isnumeric(hEvent)
        disp(sprintf('%s : %s',str,num2str(hEvent)));
        return
    end
end

disp(str);