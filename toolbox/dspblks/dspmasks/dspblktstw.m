function varargout = dspblktstw(action, varargin)
% DSPBLKTSTW Signal Processing Blockset Triggered Signal To Workspace
%   block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:07:30 $

blk = gcb;

if nargin==0, action='dynamic'; end

switch action
case 'dynamic'
   % Dynamic dialog:
   
   en = get_param(blk,'maskenables');  
   
   % If frame-based is checked, the NumChans dialog entry
   % (en{6}) must be enabled and vice-versa.
   frame = lower(get_param(blk,'FrameBased'));
   if ~strcmp(frame, lower(en{6})),
      en{6} = frame;
      set_param(blk,'maskenables',en);
   end

case 'init'
  
  % Copy all mask entries to structure:
  n = get_param(blk,'masknames');
  params = cell2struct(varargin,n,2);

   % Update trigger:
   switch params.TriggerType
   case 1, edge='rising';
   case 2, edge='falling';
   case 3, edge='either';
   end
   trigBlk = [blk '/Trigger'];
   v = get_param(trigBlk,'TriggerType');
   if ~strcmp(v, edge)
      set_param(trigBlk,'TriggerType',edge);
   end
   
   % Update workspace variable name:
   stwBlk = [blk '/Signal To Workspace'];
   v = get_param(stwBlk, 'VariableName');
   if ~strcmp(v, params.VariableName);
      set_param(stwBlk, 'VariableName', params.VariableName);
   end
   
   % Update frame-based checkbox:
   v = get_param(stwBlk, 'FrameBased');
   if ~strcmp(v, params.FrameBased),
      set_param(stwBlk, 'FrameBased', params.FrameBased);
   end
   
end

% [EOF] dspblktstw.m
