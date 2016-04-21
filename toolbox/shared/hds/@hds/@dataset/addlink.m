function [L,idx] = addlink(this,linkid)
%ADDLINK  Adds link variable to data set.
%
%   L = D.ADDLINK(ALIAS) adds a data link with name ALIAS
%   to the data set D.  A data link is a variable containing
%   an array of dependent data sets.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:16 $

% Create variable if non existent
[L,idx] = findlink(this,linkid);
if isempty(L)
   % Create new variable 
   L = hds.variable(linkid);
   % Create associated value array
   LinkArray = hds.LinkArray;
   LinkArray.Alias = L;
   this.Children_ = [this.Children_ ; LinkArray];
   idx = length(this.Children_);
   % Add instance property named after variable (user convenience)
   p = schema.prop(this,L.Name,'MATLAB array');   
   p.GetFunction = @(this,Value) localGetValue(this,Value);
   p.SetFunction = @(this,Value) localSetValue(this,Value);
end

   % Access functions (nested)
   function A = localGetValue(this,A)
      LinkArray = getContainer(this,L); % robust to change in container
      A = getArray(LinkArray);
   end

   function A = localSetValue(this,A)
      LinkArray = getContainer(this,L); 
      GridSize = getGridSize(this);
      try
         if isequal(A,[])
            LinkArray.setArray([]);
         elseif isscalar(A) && all(GridSize)
            % Optimized support of scalar expansion
            LinkArray.setScalar(A,GridSize);
         else
            % Validate array size (also updates grid size if undefined) and
            % array contents through setArray
            % REVISIT: {} = workaround dispatching woes when NewValue is an object,
            % e.g., lti
            LinkArray.setArray(this.utCheckArraySize({A},L,true))
         end
      catch
         rethrow(lasterror)
      end
      A = [];
   end

end
