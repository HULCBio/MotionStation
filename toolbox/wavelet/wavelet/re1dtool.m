function varargout = re1dtool(option,varargin)
%RE1DTOOL Regression estimation 1-D tool.
%   VARARGOUT = RE1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Nov-98.
%   Last Revision: 05-Jul-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:48:03 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
if ~isequal(option,'create') , win_tool = varargin{1}; end
switch option
  case 'create'
    win_tool = wdretool('createREG');
    if nargout>0 , varargout{1} =  win_tool; end

  case 'close' , wdretool('close');

  otherwise
    errargt(mfilename,'Unknown Option','msg');
    error('*');
end
