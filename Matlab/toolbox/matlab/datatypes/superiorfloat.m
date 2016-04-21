function  classname = superiorfloat(varargin)
%SUPERIORFLOAT errors when superior input is neither single nor double.
  
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/03/02 21:47:01 $

err.identifier = 'MATLAB:datatypes:superiorfloat';
callername = evalin('caller','mfilename');
if isempty(callername)
   err.message = ['Inputs must be floats, namely single or double.'];
else
   err.message = ['Inputs to ' callername ...
      ' must be floats, namely single or double.'];
end
rethrow(err)
