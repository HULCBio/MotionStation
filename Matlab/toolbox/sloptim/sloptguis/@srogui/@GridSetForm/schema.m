function schema
% Literal specification for grid of uncertain parameter values.
% (used as data model in UncertaintyDialog table)

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:04 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
pk = findpackage('srogui');
c = schema.class(pk,'GridSetForm',findclass(pk,'UncSetForm'));
c.Description = 'Literal specification of grid of uncertain parameter values';

% Parameters = struct with fields Name, Nominal, Min, Max
