function varargout = dspblkmview2(varargin)
% DSPBLKMVIEW2 Signal Processing Blockset matrix viewer block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.3 $ $Date: 2004/04/12 23:06:57 $

% Params structure fields:
%
% (1) ImageProperties: checkbox
%  2  CMapStr: Nx3 colormap matrix (string)
%  3  YMin: minimum Z-limit
%  4  YMax: maximum Z-limit
%  5  AxisColorbar: checkbox
%
% (6) AxisParams: checkbox
%  7  AxisOrigin
%  8  XLabel
%  9  YLabel
% 10  ZLabel
% 11  FigPos: figure position
% 12  AxisZoom: checkbox

% Copy all mask entries to structure:
blk=gcbh;
n = get_param(blk,'masknames');
s = cell2struct(varargin,n(2:end),2);
varargout{1} = s;

% disp('dspblkmview: need to call DialogApply...');
sdspmview2([],[],[],'DialogApply',s);
% [EOF] dspblkmview2.m
