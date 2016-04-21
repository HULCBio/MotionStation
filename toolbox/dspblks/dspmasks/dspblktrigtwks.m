function varargout = dspblktrigtwks(action, varargin)
% DSPBLKTSTW Signal Processing Blockset Triggered To Workspace
%   block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.4.4.3 $ $Date: 2004/04/12 23:07:27 $

obj = get_param(gcbh,'object');

if nargin==0, action='dynamic'; end

switch action

case 'init'
  
   % Update trigger:
   switch varargin{1}
   case 1, edge='rising';
   case 2, edge='falling';
   case 3, edge='either';
   end
   trigObj = get_param([gcb '/Trigger'],'object');
   trigObj.TriggerType = edge;
   
   % Update To Workspace block:
   stwObj = get_param([gcb '/To Workspace'],'object');
   stwObj.VariableName = obj.VariableName;
   stwObj.FixptAsFi    = obj.FixptAsFi;
end

% [EOF] dspblktrigtwks.m
