function daqschool(varargin)
%% DAQSCHOOL Launch Data Acquisition Toolbox tutorials.
%
%    DAQSCHOOL launches the Data Acquisition Toolbox Tutorials 
%    interface.
%   
%    The demos include an introduction to analog input, analog output
%    and digital I/O objects, channel and line manipulation, triggering,
%    saving and loading the data acquisition session, data logging 
%    and callback functions.
%

%    MP 11-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.5 $  $Date: 2003/08/29 04:45:08 $

%%
s = warning('backtrace', 'off');
warning('daqdemos:daqschool:obsolete','DAQSCHOOL is obsolete and will be discontinued. Use DEMO instead.')
warning(s);

demo toolbox Data' Acquisition'
