function varargout = dspblkstw2(varargin)
%DSPBLKSTW2 Signal Processing Blockset Signal To Workspace block helper
%function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:07:23 $

thisObj = get_param(gcbh,'object');
twksObj = get_param([gcb '/To Workspace'],'object');

twksObj.VariableName = thisObj.VariableName;
twksObj.FixptAsFi = thisObj.FixptAsFi;
varargout{1} = strncmp(thisObj.FrameMode,'Concat',6);

% [EOF] dspblkstw2.m
