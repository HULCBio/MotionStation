function hgcData=gethgcdata(z,varargin)
%GETHGCDATA retrieves Simulink-related CDATA for buttons
%   CDATA=GETHGCDATA(ZHGMETHODS)
%   CDATA=GETHGCDATA(ZHGMETHODS,COLORSPEC) defines the background color
%
%   See also RPTCOMPONENT/GETCDATA

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:40 $

hgDir = fileparts(mfilename('fullpath'));

hgcData=getcdata(rptcomponent,fullfile(hgDir,'hgcdata.mat'),varargin{:});