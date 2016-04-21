function eout = horzcat(e1,e2)
%HORZCAT Overloaded horisontal concatenation for events
%
%   Authors: James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:33:13 $


% Extract unique event handles
eout = builtin('horzcat',e1,e2);
    
% Translate names into unambiguous numerical identifiers
[unames,junk,I] = unique(get(eout(:),{'Name'}));

% Get times as numeric array
times = cell2mat(get(eout(:),{'Time'}));

% Find unique times and names
[junk, U] = unique([I times],'rows');
eout = eout(U);

        
        
            