function data = mech_get_expressions(sys)
%MECH_GET_EXPRESSIONS - get expressions for values that contribute to the 
%   SimMechanics runtime parameters
%
%   DATA=MECH_GET_EXPRESSIONS(MODEL) - returns a structure array that contains
%   expression data for MODEL.  There is an entry in the structure array for
%   each machine in the model.
%
%   DATA(I).Root        - root block of the machine (root ground)
%   DATA(I).Expressions - cell array of strings, each of which is an
%                         expression contributing the the runtime
%                         parameters
%   DATA(I).Indexes     - Mx2 array each row of which contains the
%                         corresponding indexes into the runtime parameter
%                         of each expression in the Expressions field.
%                         These indexes are zero based and of the
%                         [first, last) form.
%
%   The returned data is based on the most recent compilation of the model,
%   e.g., update digram, simulation or RTW build.  If the given model has
%   not yet been compiled or contains no SimMechanics machines the returned
%   data will be empty.
%
%   The resulting expressions DO NOT reflect parameter in-lining or global
%   tunable parameters.
  
% $Revision: 1.1 $ $Date: 2002/10/18 19:41:16 $ $Author: nbrewton $
% Copyright 2002 The MathWorks, Inc.

if nargin < 1,
  sys = gcs;
end

data = get_expressions(sys);

% [EOF] mech_get_expressions.m





