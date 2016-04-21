function varargout=ltimask(Action,varargin)
%LTIMASK  Initialize Mask for LTI block.
%
%  This function is meant to be called only by the LTI Block mask.
%
%  See also CSTBLOCKS, TF, SS, ZPK.

%   Authors: Kevin Kohrt, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.35.4.2 $ $Date: 2004/04/10 23:13:39 $

lwarn = lastwarn;warn = warning('off');

switch Action,
   case 'Initialize',
      % Used both for initializing and updating after Apply
      % RE: The mask variable sys and IC (X0) are automatically reevaluated
      %     in the proper workspace when the mask init callback is executed.
      [CB,sys,X0] = deal(varargin{:});

      % Check mask data (already evaluated)
      [A,B,C,D,Ts,Tdi,Tdo,X0,sysname] = LocalCheckData(CB,sys,X0);

      % Return data to Mask workspace (for initialization of blocks underneath)
      varargout = {A,B,C,D,Ts,Tdi,Tdo,X0,sysname};

   case 'UpdateDiagram'
      % Updates diagram (separate from Initialize so that all mask
      % variables are resolved when updating, see g207027)
      LocalUpdateDiagram(varargin{:});

   case 'MaskLTICallback'
      % Callback from editing LTI system field
      % RE: 1) Only enables/disables the X0 edit field. Do not attempt to run mask
      %        init (would disable Cancel) or reset dialog entries here (must wait
      %        for Apply)
      %     2) Callback name hardwired in block property 'MaskCallbacks'
      CB = varargin{1};
      MaskVal = get_param(CB,'MaskValues');
      sys = evalin('base',MaskVal{1},'[]');
      if isempty(sys)
         return
      elseif isa(sys,'ss')
         set_param(CB,'MaskEnables',{'on';'on'})
      else
         set_param(CB,'MaskEnables',{'on';'off'})
      end

   case 'InitializeVars',
      %---This is an obsoleted callback from versions 4.0.1,4.1 versions of
      % the LTI block. It is now used to update this blocks to the current
      % LTI block in the cstblocks.mdl library
      %---For now, just warn the user that they need to update their diagram
      msgbox({'Your Simulink model uses an old version of the LTI Block.'; ...
         ''; ...
         'Use the function CSTUPDATE to update all LTI Blocks in the '; ...
         'Simulink model.'}, ...
         'LTI Block Warning','replace');

end

warning(warn);lastwarn(lwarn);

%-------------------------------Internal Functions----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCheckData %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A,B,C,D,Ts,Tdi,Tdo,X0,sysname] = LocalCheckData(CB,sys,X0)
% Checks system data

% Defaults
A=[]; B=[]; C=[]; D=1; Tdi=0; Tdo=0; Ts=0; sysname = '???';
MaskVal = get_param(CB,'MaskValues');

% Convert double to SS
if isa(sys,'double') & ~isempty(sys)
   sys = ss(sys);
end

% Check type and dimension of LTI object
if ~isa(sys,'lti'),
   LocalLTIError('The LTI system variable must be a valid LTI model.')
elseif isa(sys,'frd')
   % FRDs not supported
   LocalLTIError('The LTI block does not support FRD models.');
elseif ndims(sys)>2,
   % LTI Arrays not supported
   LocalLTIError('The LTI block does not support arrays of LTI models.');
elseif ~isproper(sys)
   % Simulink does not handle improper systems
   LocalLTIError('The LTI block does not support improper models.');
else
   if ~isct(sys)
      % Absorb delays in discrete-time case
      old_order = size(sys,'order');
      sys = delay2z(sys);
      new_order = size(sys,'order');
      if ~isequal(X0,0)
         X0 = [X0(:) ; zeros(new_order-old_order,1)];
      end
   end

   % Extract state-space data
   [A,B,C,D,Ts] = ssdata(sys);
   Ts = abs(Ts);
   sysname = MaskVal{1};

   % Check Transport delay
   DelayData = get(sys,{'inputdelay','outputdelay','iodelay'});
   [Tdi,Tdo,Tdio] = deal(DelayData{:});
   Tdi = Tdi';
   Tdo = Tdo';
   if any(Tdio(:)),  % i/o delays not supported
      LocalLTIError('I/O delays are ignored by the LTI block.');
   end

   % Validate initial condition
   % RE: Make sure SET_PARAM never executes during initialization (recursive call -> error)
   is_ss = isa(sys,'ss');
   if ~is_ss & ~isempty(X0)
      % Ignore initial condition
      try
         % Only for dialog's Apply callback. Errors out when called during mask init.
         set_param(CB,'MaskValues',{MaskVal{1};'[]'})
      end
      X0 = 0;
   elseif is_ss & ~any(length(X0)==[1 size(sys,'order')])
      % Wrong length
      if ~isempty(X0)
         LocalLTIError(sprintf('%s\n%s',...
            'Length of Initial State vector does not match number of states.',...
            'Using zero Initial State instead.'))
      end
      try
         % Only for dialog's Apply callback. Errors out when called during mask init.
         set_param(CB,'MaskValues',{MaskVal{1};'0'})
      end
      X0 = 0;
   end

   % Correctly set enable state of IC edit box
   if isa(sys,'ss')
      set_param(CB,'MaskEnables',{'on';'on'})
   else
      set_param(CB,'MaskEnables',{'on';'off'})
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalUpdateDiagram %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateDiagram(CB,Ts)

SSBlockName = strvcat(...
   find_system(CB,'FollowLinks','on','LookUnderMasks','all','blocktype','StateSpace'),...
   find_system(CB,'FollowLinks','on','LookUnderMasks','all','blocktype','DiscreteStateSpace'));
if size(SSBlockName,1)~=1
   % Should never happen
   return
end
IsDiscreteBlock = strcmp(get_param(SSBlockName,'blocktype'),'DiscreteStateSpace');

% Flag for Input Transport Delay
HasDelayBlock = ~isempty(find_system(CB,...
   'FollowLinks','on', ...
   'LookUnderMasks', 'all', ...
   'MaskType','Transport Delay (masked)', ...
   'Tag','InputDelayBlock'));
if ~HasDelayBlock, % It got deleted some how, add it back.
   % In1 may or may not be present ... check?
   delete_line(CB,'In1/1','Internal/1');
   add_block('cstextras/Transport Delay (masked)',[CB '/Tdi'], ...
      'DelayTime', 'Tdi', 'Position', [70 30 100 60],...
      'Tag','InputDelayBlock');
   add_line(CB,'In1/1','Tdi/1'      );
   add_line(CB,'Tdi/1' ,'Internal/1');
end % if ~HasDelayBloc

% Flag for Output Transport Delay
HasDelayBlock = ~isempty(find_system(CB,...
   'FollowLinks','on', ...
   'LookUnderMasks', 'all', ...
   'MaskType','Transport Delay (masked)', ...
   'Tag','OutputDelayBlock'));
if ~HasDelayBlock, % It got deleted some how, add it back.
   % Out1 may or may not be present ... check?
   delete_line(CB,'Internal/1','Out1/1');
   add_block('cstextras/Transport Delay (masked)',[CB '/Tdo'], ...
      'DelayTime', 'Tdo', 'Position', [255 30 285 60],...
      'Tag','OutputDelayBlock');
   add_line(CB,'Internal/1','Tdo/1');
   add_line(CB,'Tdo/1','Out1/1');
end % if ~HasDelayBlock

% Discrete/Continuous checks
if xor(IsDiscreteBlock,Ts)
   % System is discrete but current block is continuous, or converse
   Orient = get_param(SSBlockName,'orientation');
   Size = get_param(SSBlockName,'position');
   delete_block(SSBlockName);
   if Ts
      add_block('built-in/DiscreteStateSpace',SSBlockName, ...
         'Orientation',Orient, 'Position'   ,Size);
      set_param([CB,'/Internal'], ...
         'A'          ,'A' , ...
         'B'          ,'B' , ...
         'C'          ,'C' , ...
         'D'          ,'D' , ...
         'X0'         ,'X0', ...
         'SampleTime' ,'Ts');
   else
      add_block('built-in/StateSpace',SSBlockName, ...
         'Orientation',Orient        , ...
         'Position'   ,Size);
      set_param([CB,'/Internal'], ...
         'A'          ,'A' , ...
         'B'          ,'B' , ...
         'C'          ,'C' , ...
         'D'          ,'D' , ...
         'X0'         ,'X0');
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLTIError(msg)
% Display error messages

InitFlag=strcmp(get_param(bdroot(gcb),'SimulationStatus'),'initializing');
if InitFlag,
   errordlg(msg,'Simulink Initialization Error','replace');
else
   errordlg(msg,'LTI Block Error','replace');
end
