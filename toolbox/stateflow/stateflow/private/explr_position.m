function result = explr_position(method,varargin)
% This function is called by th explorer at
% construction and destruction time to
% load and save explr position to make 
% it  persistent across sessions. 
% Makes use of MATLAB pref management mechanism.
% G100639
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:57:40 $

switch(method)
case 'load'
    if(ispref('Stateflow','explorerPosition'))
        pos = getpref('Stateflow','explorerPosition');
    else
        pos = [0 0 0 0];
    end
    result = pos;
case 'save'
    figH = varargin{1};
    pos = get(figH,'Position');
    setpref('Stateflow','explorerPosition',pos);
    result = [];
end