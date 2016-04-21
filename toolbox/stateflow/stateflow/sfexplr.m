function varargout = sfexplr( varargin )
% SFEXPLR Launches the Stateflow Explorer.

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13.2.1 $  $Date: 2004/04/15 01:01:38 $

	if nargout>0
		varargout = cell(1,nargout);
		[varargout{:}] = sf('Explr', varargin{:} );
	else sf('Explr', varargin{:} );
	end
