function varargout = interfaces(obj)
%INTERFACES List custom interfaces supported by a COM server.
%   S =INTERFACES(OBJ) returns cell array of strings S listing all custom 
%   interfaces implemented by the component in a specific COM server. The 
%   server is designated by input argument, OBJ, which is the handle 
%   returned by the ACTXCONTROL or ACTXSERVER function when creating that 
%   server.
%
%   Equivalent syntax is
%      S = OBJ.INTERFACES
%
%   h = actxserver('mytestenv.calculator') 
%   h =
%       COM.mytestenv.calculator
%   customlist = h.interfaces
%   customlist =
%          ICalc1
%          ICalc2
%          ICalc3
%
%   See also  WINFUN/ACTXSERVER, WINFUN/ACTXCONTROL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/01/02 18:06:04 $
