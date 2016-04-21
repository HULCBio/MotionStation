function [v,idx] = addvar(this,varid)
%ADDVAR  Adds variable to data set.
%
%   V = D.ADDVAR(VARNAME) or V = D.ADDVAR(VARHANDLE)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:18 $
v = hds.variable(varid);
if all(v~=getvars(this))
   % Create associated value array
   ValueArray = hds.BasicArray;
   ValueArray.Variable = v;
   this.Data_ = [this.Data_ ; ValueArray];
   idx = length(this.Data_);
   % Add instance property named after variable (user convenience)
   p = schema.prop(this,v.Name,'MATLAB array');
   p.GetFunction = @(this,Value) localGetValue(this,Value);
   p.SetFunction = @(this,Value) localSetValue(this,Value);
   p.AccessFlags.AbortSet = 'off';  % avoids triggering GET for every SET
end

   % Access functions (nested)
   function A = localGetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      A = getArray(ValueArray);
      GridSize = getGridSize(this);
      if ~isempty(A) && all(GridSize>0)
         GridDim = locateGridVar(this,v);
         if ~isempty(GridDim) && any(GridSize(2:end)>1)
            % Replicate to grid size
            % RE: Grid variables have SampleSize=[1 1]
            A = this.utGridFill(A,GridSize,GridDim);
         elseif isempty(GridDim) && isscalar(A) && any(GridSize>1)
            % Scalar expansion
            A = hdsReplicateArray(A,GridSize);
         end
      end
   end

   function A = localSetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      try
         % Validate array size (also updates grid size if undefined)
         % REVISIT: {} = workaround dispatching woes when NewValue is an object,
         % e.g., lti
         if isscalar(A) && all(getGridSize(this)>0)
            % Optimized support of scalar expansion
            ValueArray.SampleSize = [1 1];
            ValueArray.setArray(A);
         else
            [NewValue,GridSize,SampleSize] = ...
               utCheckArraySize(this,{A},v,ValueArray.GridFirst);
            % Store data (may fail if array container is read only)
            ValueArray.SampleSize = SampleSize;
            ValueArray.setArray(ValueArray.utReshape(NewValue,GridSize))
         end
      catch
         rethrow(lasterror)
      end
      A = [];
   end

end
