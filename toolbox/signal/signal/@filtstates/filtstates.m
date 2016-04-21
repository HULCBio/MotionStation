function varargout = filtstates(varargin)
%FILTSTATES   Filter States object.
%   H = FILTSTATES.DFIIR(NUMSTATES,DENSTATES) constructs an object and sets
%   its 'Numerator' and 'Denominator' properties to NUMSTATES and DENSTATES
%   respectively.  
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point
%   Toolbox, enables single precision floating-point and fixed-point
%   support for the Numerator and Denominator states.
%
%   The following methods are available for the DFIIR object (type
%   help filtstates/METHOD to get help on a specific method - e.g. help
%   filtstates/double):
%
%   filtstates/double - Convert a FILTSTATES object to a double vector.
%   filtstates/single - Convert a FILTSTATES object to a single vector.
%
%   For more information, enter doc filtstates at the MATLAB command line.
    
%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:55 $

% Help for instantiating a FILTSTATES object.

msg = sprintf(['Use FILTSTATES.DFIIR to create a filter states object.\n']);
error(msg)

% [EOF]














