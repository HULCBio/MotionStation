function varargout = invoke(obj, varargin)
%INVOKE Invoke method on object or interface, or display methods.
%   S = INVOKE(OBJ) returns structure array S containing a list of 
%   all methods supported by the object or interface OBJ along 
%   with the prototypes for these methods.
%
%   Equivalent syntax is
%      S = OBJ.INVOKE
%
%   S = INVOKE(OBJ, METHOD) invokes the method specified in the 
%   string METHOD, and returns an output value, if any, in S. 
%   The data type of the return value is dependent upon the specific 
%   method being invoked and is determined by the specific control 
%   or server.
%
%   Equivalent syntax is
%      S = OBJ.METHOD  %(if typelibrary is available)
%
%   S = INVOKE(OBJ, METHOD, ARG1, ARG2, ...) invokes the method 
%   specified in the string METHOD with input arguments ARG1, 
%   ARG2, etc.
%
%   S = INVOKE(OBJ, CUSTOMINTERFACENAME) returns an Interface object 
%   that serves as a handle to a custom interface implemented by the 
%   COM component, OBJ. The CUSTOMINTERFACENAME argument is a quoted 
%   string returned by the INTERFACES function.
%
%   S = INVOKE(OBJ, GUID) returns an Interface object that serves as a 
%   handle to a custom interface implemented by the COM component, OBJ. 
%   The GUID argument is a quoted string that represents the 128 bit number
%   of a particular Interface or COClass. 
%
%   Example:
%       h = actxcontrol ('mwsamp.mwsampctrl.1');
%       s = h.invoke;
%       h.set('Radius', 100);
%       s = h.invoke('Redraw'); OR h.Redraw
%       h = actxserver('mytestenv.calculator');
%       customlist = h.interfaces;
%       customlist =
%           ICalc1
%           ICalc2
%           ICalc3
%       %Get custom interface ICalc
%       c1 = h.invoke('ICalc1');
%       %Get custom interface represented by the following CoClass GUID
%       c2 = h.invoke('BC660790-3FE2-4679-B2BA-84B6723A14C1');
%
%   See also  COM/INTERFACES.

% Copyright 1984-2003 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $ $Date: 2004/01/02 18:06:05 $
