function index = openSelectedMsg(h)
%  OPENSELECTEDMSG
%  This function will open the selected message
%  for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
   
%  $Revision: 1.1.6.2 $ 

  
%Set selected row

index = h.rowOpen;

if (index <= 0)
  error('Error in openSelectedMsg index out of bounds');
  return;
end
blkHandle = [];
msg = h.Messages(index);
% If there is an open function simply call
% evaluation for that function
if ~isempty(msg.openFcn) 
  try, 
    eval(msg.openFcn);
  catch,
    disp('Error calling custom callback');
  end;
else,
  if (~isempty(msg.AssocObjectHandles))
    for i = 1:length(msg.AssocObjectHandles)
      blkHandle = msg.AssocObjectHandles(i);
      if strcmp(get_param(blkHandle,'Type'),'block') & ...
            ~strcmp(get_param(blkHandle,'iotype'),'none')
        bd = bdroot(blkHandle);
        iomanager('Create',bd);
      else
        hilite_system(blkHandle,'error');	 
      end;
    end;
  else,
    if ~isempty(msg.sourceObject),
      switch ml_type(msg.sourceObject, 1),
       case 'sl_handle', open_system(msg.sourceObject, 'force');
       case 'sf_handle', sf('Open', msg.sourceObject);
       otherwise,
      end;
    else,
      if ~isempty(msg.SourceFullName),
        try, open_system(msg.sourceFullName); end;
      end;
    end; 
  end;   
    %
  % Open the selected Object
  %
  switch msg.component,
   case 'Simulink',
    if ~isempty(blkHandle),
      try, open_block_and_parent_l(blkHandle); end; % try
    end;
   case 'Stateflow',
    if ~isempty(blkHandle) open_system(blkHandle); end;
    if ~isempty(msg.sourceObject), sf('Open', msg.sourceObject); end;
  end;
  
  end;
%
function [theType, conflict] = ml_type(obj, sfIsHere),
%ML_TYPE  Extracts the type of the given input wrt standard MATLAB types,
%         HG, Simulink, and Stateflow handles.  Handle conflicts between
%         Stateflow and Simulink or Stateflow and HG are detected if requested.
  if nargin < 2, sfIsHere = stateflow_is_here_l; end;

  theType = 'unknown';
  conflict = logical(0);
  if iscell(obj),       theType = 'cell';               return; end;
  if isobject(obj),
    theType = 'object';
    switch(class(obj)),
     case 'activex', theType = 'activex';
    end;
    return;
  end;

  if ischar(obj),          theType = 'string';  return; end;
  if islogical(obj), theType = 'bool';  return; end;
  if isstruct(obj),  theType = 'struct';        return; end;

  %
  % Resolve handle (Stateflow handles take precedence if it is present).
  %
  if isnumeric(obj),
    if ~isempty(obj),
      if (sfIsHere & obj==fix(obj) & sf('ishandle', obj)),
        theType = 'sf_handle';
        if (nargout < 2), return; end;
      end;
      if ishandle(obj),
        if isempty(find_system('handle', obj)),
          if nargout > 1 & strcmp(theType, 'sf_handle'), conflict = logical(1);
          else, theType = 'hg_handle';
          end
          return;
        else,
          if nargout > 1 & strcmp(theType, 'sf_handle'), conflict = logical(1);
          else, theType = 'sl_handle';
          end;
          return;
        end;
      end;
    end;

    theType = 'numeric';
  end;





