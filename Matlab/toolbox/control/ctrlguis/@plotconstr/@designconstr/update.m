function update(Constr, varargin)
%UPDATE  Updates constraint display when data changes.
%
%   Main method for updating the display when the constraint
%   data changes.  Issues a DataChanged event to notify all
%   observers that the data changed (no listeners on individual
%   data properties).

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:12:07 $

if Constr.Activated
   % Protect against illicit calls during undo add
   Constr.render;  % rerender
   % Notify observers of data change
   Constr.send('DataChanged')
end