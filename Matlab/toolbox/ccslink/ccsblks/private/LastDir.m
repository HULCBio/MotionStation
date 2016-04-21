function varargout = LastDir(varargin)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:49 $

persistent DIRNAME;

opt = varargin{1};
switch opt
    case 'set',
        DIRNAME = varargin{2};
    case 'get',
        if isempty(DIRNAME),
            DIRNAME = pwd;
        end            
        varargout{1} = DIRNAME;
end
