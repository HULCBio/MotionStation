function addproperty(varargin)
%ADDPROPERTY Add custom property to an object.
%   ADDPROPERTY(OBJ, PROPERTYNAME) adds the custom property specified in the
%   string, PROPERTYNAME, to the object or interface, OBJ. Use SET to
%   assign a value to the property.
%
%   Equivalent syntax is
%       OBJ.ADDPROPERTY(PROPERTYNAME)
%
%   Example:
%   %Create an mwsamp control and add a new property named Position to it.
%   %Assign an array value to the property
%   f = figure('position', [100 200 200 200]);
%   h = actxcontrol('mwsamp.mwsampctrl.2', [0 0 200 200], f);
%   h.get
%        Label: 'Label'
%       Radius: 20
%
%   h.addproperty('Position');
%   h.set('Position', [200 120]);
%   h.get
%        Label: 'Label'
%       Radius: 20
%     Position: [200 120]
%
%   h.get('Position')
%   ans =
%      200   120
%
%   See also COM/DELETEPROPERTY, COM/GET, COM/SET

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/02 18:05:59 $
