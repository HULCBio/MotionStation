function slcData=getslcdata(z,varargin)
%GETSLCDATA retrieves Simulink-related CDATA for buttons
%   CDATA=GETSLCDATA(ZSLMETHODS)
%   CDATA=GETSLCDATA(ZSLMETHODS,COLORSPEC) defines the background color
%
%   See also RPTCOMPONENT/GETCDATA

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:35 $

slcData=getcdata(rptcomponent,...
	fullfile(fileparts(mfilename('fullpath')),'slcdata.mat'),...
	varargin{:});

