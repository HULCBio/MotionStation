function [hDatatip] = createDatatip(hThis,hHost)

% Copyright 2002-2003 The MathWorks, Inc.

if(hThis.Debug)
  disp('createDatatip')
end

hDatatip = localCreateDatatip(hThis,hHost);
 
% Add string function to datatip
stringFcn = get(hThis,'DatatipStringFcn');
if ~isempty(stringFcn)
  set(hDatatip,'StringFcn',stringFcn);
end

% Make datatip visible 
set(hDatatip,'Visible','on');

% Assign this object as the datatip's manager
set(hDatatip,'DatatipManagerHandle',hThis);

% Add to vector
set(hThis,'DatatipHandles',[hDatatip; hThis.DatatipHandles]);

% Make current
set(hThis,'CurrentDatatip',hDatatip);

%--------------------------------------------%
function [hDatatip] = localCreateDatatip(hThis,hHost)

hDatatip = [];

% Create datatip based on function handle
fcn = get(hThis,'DatatipCreateFcn');
if ~isempty(fcn) 
   if iscell(fcn) & length(fcn) > 0 
      if length(fcn)==1
         hDatatip = feval(fcn{1},hHost);
      else
         hDatatip = feval(fcn{1},hHost,strFcn{2:end});
      end
   elseif isa(fcn,'function_handle')
       hDatatip = feval(fcn,hHost);
   end
end

% Create default datatip 
if isempty(hDatatip)
   hDatatip = graphics.datatip(hHost);
end




