function [resolvedPortHandle, varargout] = slresolveporthandle(portHandle)

%
% Potential issue with unconnected signals in determining the
% "block context".
%

%   Copyright 2000-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:49:40 $

  nout = max(nargout,1)-1;
  
  [resolvedPortHandle, errmsg] = slResolvePortHandleWithErrorReturn(portHandle);

  if ((nout < 1) & ~isempty(errmsg)),
    error(errmsg);
  else;
    varargout(1) = {errmsg};
  end;
  
function [udiH, errmsg] = slResolvePortHandleWithErrorReturn(portHandle)
  errmsg = [];
  udiH = [];
  
  % filter non-port handle input
  ArgType = get_param(portHandle,'Type');
  if ~strcmp(ArgType,'port'),
    errmsg = 'Given port handle does not have type port';
    return;    
  else
    % get truth of port's 'TestPoint' == 'on'.
    %
    isTestPointOn = strcmp('on',get_param(portHandle,'TestPoint'));

    % get truth of port's 'RTWStorageClass' == 'Auto'.
    %
    isStorageClassAuto = strcmp(get_param(portHandle,'RTWStorageClass'),'Auto');

    % get the port's 'ResolveTo'.
    %
    resLabel = get_param(portHandle,'ResolveTo');

    % get the port's 'Name'.
    %
    sigLabel = get_param(portHandle,'Name');
    
    % get the port's parent block to use as context for resolving.
    %
    parent = get_param(portHandle,'Parent');
    
    % get the block diagram's 'ResolveSignalLabels'/'GloballyResolveTo'
    % characteristic, which must be true to resolved a port name to a
    % Simulink.Signal in the workspace.
    %
    BlockDiagramRoot = bdroot(parent);
    try
      CharacteristicName = 'GloballyResolveTo';
      global_resolve = strcmp('on',get_param(BlockDiagramRoot,CharacteristicName));
    catch
      CharacteristicName = 'ResolveSignalLabels';
      global_resolve = strcmp('on',get_param(BlockDiagramRoot,CharacteristicName));
    end;
    
    if ~isempty(resLabel),
      % If there is a 'ResolveTo' label it MUST resolve to a
      % 'Simulink.Signal'
      
      % This case must not have TestPoint 'on' for the port.
      %
      if (isTestPointOn),
	errmsg = ['port has TestPoint == True and a ResolveTo label'];
	return;    
      end;

      % This case must have RTWStorageClass 'Auto'
      %
      if (~isStorageClassAuto);
	errmsg = ['port has RTWStorageClass == Auto and a ResolveTo label'];
	return;    
      end;

      % Try to resolve the 'ResolveTo' value
      %
      try
	udiH = slResolve(resLabel, parent);
      catch
	udiH = [];
      end;
      
      if isempty(udiH),
	errmsg = ['Failed to resolve: ''' resLabel ''''];
	return;    
      end;
      
      if ~isa(udiH,'Simulink.Signal'),
	errmsg = ['Resolved to non-signal: ''' resLabel ''''];
	return;
      else
	% Resolved
	return;
      end;
    elseif ~isempty(sigLabel) & ...
	  global_resolve & ...
	  (~isTestPointOn) & ...
	  (isStorageClassAuto),
      % When there is no 'ResolveTo' label the port handle can
      % still be resolved to a 'Simulink.Signal' by signal label
      % provided global resolution is enabled, the port does not
      % have TestPoint set and the port's RTWStorageClass is
      % 'Auto'.
      %

      % Try to resolve the 'Name' value
      %
      try
	udiH = slResolve(sigLabel, parent);
      catch
	udiH = [];
      end;
      
      if ~isempty(udiH) & ...
	    isa(udiH,'Simulink.Signal'), 
	% Resolved
	return;
      else 
	% It's ok not to resolve through the signal label. 
	udiH = [];
      end;
    end;

    return;
    
  end;

