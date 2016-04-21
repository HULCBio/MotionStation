function out = fieldnames(obj, flag)
%FIELDNAMES Get IVI Configuration Store object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with IVI Configuration Store
%   object, OBJ. OBJ can be an array of IVI Configuration Store objects.
%

%   MP 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:32 $

if ~isa(obj, 'iviconfigurationstore')
    error('iviconfigurationstore:fieldnames:invalidOBJ', 'OBJ must be an IVI Configuration Store object.');
end

out = fieldnames(get(obj));
