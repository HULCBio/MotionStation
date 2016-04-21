function fireprintbehavior(h,callbackName)
%FIREPRINTBEHAVIOR Fire callback for Print behavior customization
%    Helper function for printing. Do not call directly.

%   Copyright 1984-2003 The MathWorks, Inc.

allobj = findall(h);
for k=1:length(allobj)
  if ishandle(allobj(k)) % callbacks might delete other handles
    behavior = hggetbehavior(allobj(k),'Print','-peek');
    if ~isempty(behavior) && ~isempty(get(behavior,callbackName))
      cb = get(behavior,callbackName);
      if isa(cb,'function_handle')
        cb(handle(allobj(k)),callbackName);
      elseif iscell(cb)
        if length(cb) > 1
          feval(cb{1},handle(allobj(k)),callbackName,cb{2:end});
        else
          feval(cb{1},handle(allobj(k)),callbackName);
        end
      else
        feval(cb,handle(allobj(k)),callbackName);
      end
    end
  end
end
