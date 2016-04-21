function firePropertyChange(this, propertyName, varargin)
% FIREPROPERTYCHANGE Fires PropertyChange event to listeners with data attached.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:39 $

% Parse input
if nargin == 2
  oldValue = '';
  newValue = '';
elseif nargin == 3
  oldValue = varargin{1};
  newValue = '';
elseif nargin >= 4
  oldValue = varargin{1};
  newValue = varargin{2};
end

% Fire PropertyChange event
this.send('PropertyChange', ...
          explorer.dataevent(this, propertyName, oldValue, newValue));
