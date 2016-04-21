function varargout = democ_action(varargin)
%DEMOC_ACTION Introduction to instrument control action functions.
%
%   DEMOC_ACTION illustrates how tasks can be performed based on the 
%   event that occurred. Supported events include bytes available, 
%   output empty and error events. An example action function will
%   be shown.
%
%   See also INSTRHELP, INSTRSCHOOL.
%

%   MP 12-23-99
%   Copyright 1999-2002 The MathWorks, Inc. 
%   $Revision: 1.9.2.1 $  $Date: 2002/10/23 13:50:14 $

warning('instrumentdemos:democ_action:obsolete','DEMOC_ACTION is obsolete and will be discontinued. Use DEMOC_CALLBACK instead.')
varargout = democ_callback(varargin{:});