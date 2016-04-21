function deleteproperty(varargin)
%DELETEPROPERTY Remove custom property from object.
%   DELETEPROPERTY(OBJ, PROPERTYNAME) deletes the property specified in the
%   string PROPERTYNAME from the custom properties belonging to object or
%   interface, OBJ.
%
%   Equivalent syntax is
%       OBJ.DELETEPROPERTY(PROPERTYNAME)
%
%   Example:
%   %Create an mwsamp control and add a new property named Position to it.
%   %Assign an array value to the property and delete it using
%   %deleteproperty.
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
%   h.deleteproperty('Position');
%   h.get
%        Label: 'Label'
%       Radius: 20
%
%   See also COM/ADDPROPERTY, COM/GET, COM/SET

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/02 18:06:01 $
