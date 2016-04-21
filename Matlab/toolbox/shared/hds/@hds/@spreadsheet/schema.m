function schema
% Defines properties for @spreadsheet class.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:35 $

% Register class 
pk = findpackage('hds');
c = schema.class(pk,'spreadsheet',findclass(pk,'dataset'));
