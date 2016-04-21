function instrschool(varargin)
%INSTRSCHOOL Launch Instrument Control Toolbox tutorials.
%
%   INSTRSCHOOL launches the Instrument Control Toolbox Tutorials 
%   interface.
%   

%   MP 12-23-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.11.2.3 $  $Date: 2004/01/16 20:03:33 $

s = warning('backtrace', 'off');
warning('instrumentdemos:instrschool:obsolete','INSTRSCHOOL is obsolete and will be discontinued. Use DEMO instead.')
warning(s);

demo toolbox instrument

