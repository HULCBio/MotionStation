function [x, y] = fixgeocoords(X, Y, fromval, toval)
%FIXGEOCOORDS Replace from value with to value in the coordinate arrays.
%
%   [x,y] = FIXGEOCOORDS(X,Y,FROMVAL,TOVAL) replaces the from value,
%   FROMVAL, with the to value, TOVAL, in both X and Y coordinate arrays.
%   If FROMVAL is found in either X or Y, it is replaced with the TOVAL in
%   both.
%
%   Example
%   --------
%      % Remove the NaN values in shape.X and shape.Y.
%      shape = shaperead('roads');
%      [x, y] = fixgeocoords(extractfield(shape,'X'), ...
%                            extractfield(shape,'Y'),NaN,[])
%      
%   See also EXTRACTFIELD, SHAPEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2003/12/13 02:52:33 $

if numel(X) ~= numel(Y)
   msg = 'The number of elements of X and Y must be equal.';
   eid=sprintf('%s:%s:invalidInput', getcomp, mfilename);
   error(eid,'%s', msg)
end

if isempty(fromval)
   msg = 'FROMVAL must not be empty.';
   eid=sprintf('%s:%s:invalidInput', getcomp, mfilename);
   error(eid,'%s', msg)
end

% Check for scalar quantities for from and toval
% isempty([]) returns 0 for numel
if numel(fromval) ~= 1 || (~isempty(toval) && numel(toval) ~= 1)
   msg = 'FROMVAL and TOVAL must be scalar.';
   eid=sprintf('%s:%s:invalidInput', getcomp, mfilename);
   error(eid,'%s', msg)
end

x = X;
y = Y;
if isnan(fromval)
   index = isnan(X) | isnan(Y);
else
   index = (X == fromval) | (Y == fromval);
end
if ~isempty(index)
   if isempty(toval)
      x(index) = [];
      y(index) = [];
   else
      x(index) = toval;
      y(index) = toval;
   end
end

