function z=zhgmethods(varargin)
%ZHGMETHODS information for Handle Graphics report generator components
%   ZHGMETHODS contains a structure with the following fields:
%   Z.Figure - the current looping figure
%   Z.Axis - the current looping axis
%   Z.Object - the current looping object
%
%   See also: RPTGEN

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:51 $


z.Desc='Report Generator Handle Graphics assistant';
z=class(z,'zhgmethods');
