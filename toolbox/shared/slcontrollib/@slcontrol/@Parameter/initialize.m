function initialize(this, name, varargin)
% INITIALIZE Initialize object properties
%
% BLOCK is a Simulink block name or handle.
% VARARGIN Parameter value if supplied.

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:54 $

% Check parameter name
if ~ischar(name)
   error('A parameter name should be provided as the first argument.');
end

% Try to get value from the workspace.
if ~isempty(varargin) && isnumeric( varargin{1} )
   value = varargin{1};
else
   try
      value = evalin('base', name);
   catch
      error('Variable "%s" does not exist in the workspace.', name);
   end
end

% Value from workspace might not be numeric
if ~isnumeric(value)
   error('Variable "%s" is not a numeric variable.', name);
end

% Set properties
this.Name       = name;
this.Dimensions = size(value);

% Set dependent properties
this.Value        = value;
this.InitialGuess = value;
this.Minimum      = -Inf * ones( this.Dimensions );
this.Maximum      = +Inf * ones( this.Dimensions );
this.TypicalValue = value;
