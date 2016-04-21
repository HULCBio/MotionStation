function ret_obj = clo(obj, in1, in2)
%CLO Clear object
%   CLO(H) deletes all children of the object with visible handles.
%
%   CLO(..., 'reset') deletes all children (including ones with hidden
%   handles) and also resets all object properties to their default
%   values.
%
%   CLO(..., HSAVE) deletes all children except those specified in
%   HSAVE.
%
%   See also CLF, CLA, RESET, HOLD.

%   Copyright 1984-2004 The MathWorks, Inc. 

% decode input args:
hsave    = [];
do_reset = '';

error(nargchk(1, 3, nargin));

if nargin > 1
  if   isstr(in1), do_reset = in1; else, hsave = in1; end
  if nargin > 2
    if isstr(in2), do_reset = in2; else, hsave = in2; end
  end
end

% error-check input args
if ~isempty(do_reset)
  if ~strcmp(do_reset, 'reset')
    error('Unknown command option.')
  else
    do_reset = 1;
  end
else
  do_reset = 0;
end

if any(~ishandle(hsave))
  error('Bad handle')
end

hsave = find_kids(obj, hsave);

kids_to_delete = [];
if do_reset
  kids_to_delete = setdiff(findall(obj,'serializable','on','-depth',1),obj);
else
  kids_to_delete =  findobj(get(obj,'Children'),'flat',...
      'HandleVisibility','on', 'serializable','on');
end

kids_to_delete = setdiff(kids_to_delete, hsave);

delete(kids_to_delete);

if do_reset, 
  handleobj = obj(ishandle(obj));
  reset(handleobj);
  % reset might have invalidated more handles
  handleobj = handleobj(ishandle(handleobj));
  % look for appdata for holding color and linestyle
  for k=1:length(handleobj)
    tobj = handleobj(k);
    if isappdata(tobj,'PlotHoldStyle')
      rmappdata(tobj,'PlotHoldStyle')
    end
    if isappdata(tobj,'PlotColorIndex')
      rmappdata(tobj,'PlotColorIndex')
      rmappdata(tobj,'PlotLineStyleIndex')
    end
  end
end

% now that IntegerHandle can be changed by reset, make sure
% we're returning the new handle:
if (nargout ~= 0)
    ret_obj = obj(ishandle(obj));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hsave_out = find_kids(obj, hsave)
%
%
%
hsave_out = [];
for kid=hsave(:)'
  while ~isempty(kid)
    parent = get(kid,'parent');
    if ~isempty(parent) & parent == obj
      hsave_out(end + 1) = kid;
      break;
    else
      kid = parent;
    end
  end
end
  
