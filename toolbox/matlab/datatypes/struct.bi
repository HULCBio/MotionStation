function s = struct(varargin)
%STRUCT Create or convert to structure array.
%   S = STRUCT('field1',VALUES1,'field2',VALUES2,...) creates a
%   structure array with the specified fields and values.  The value
%   arrays VALUES1, VALUES2, etc. must be cell arrays of the same
%   size, scalar cells or single values.  Corresponding elements of the
%   value arrays are placed into corresponding structure array elements.
%   The size of the resulting structure is the same size as the value
%   cell arrays or 1-by-1 if none of the values is a cell.
%
%   STRUCT(OBJ) converts the object OBJ into its equivalent
%   structure.  The class information is lost.
%
%   STRUCT([]) creates an empty structure.
%
%   To create fields that contain cell arrays, place the cell arrays
%   within a VALUE cell array.  For instance,
%     s = struct('strings',{{'hello','yes'}},'lengths',[5 3])
%   creates the 1-by-1 structure
%      s = 
%         strings: {'hello'  'yes'}
%         lengths: [5 3]
%
%   Example
%      s = struct('type',{'big','little'},'color','red','x',{3 4})
%
%   See also ISSTRUCT, SETFIELD, GETFIELD, FIELDNAMES, ORDERFIELDS, 
%   ISFIELD, RMFIELD, DEAL, SUBSTRUCT, STRUCT2CELL, CELL2STRUCT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/10 23:25:34 $
%   Built-in function.
