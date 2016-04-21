function [v,idx] = addvar(this,varid)
%ADDVAR  Adds variable to TestPoint data set.
%
%   V = T.ADDVAR(VARNAME) or V = T.ADDVAR(VARHANDLE)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:54 $

% Create variable if non existent
[v,idx] = findvar(this,varid);
if isempty(v)
   % Create new variable 
   v = hds.variable(varid);
   % Create associated value array
   ValueArray = hds.VirtualArray;
   ValueArray.GridFirst = false;  % sample size always first (grid is 1x1)
   ValueArray.Variable = v;
   this.Data_ = [this.Data_ ; ValueArray];
   idx = length(this.Data_);
   % Add instance property named after variable (user convenience)
   % Add instance property named after variable (user convenience)
   p = schema.prop(this,v.Name,'MATLAB array');
   p.GetFunction = @(this,Value) localGetValue(this,Value);
   p.SetFunction = @(this,Value) localSetValue(this,Value);
end

   % Access functions (nested)
   function A = localGetValue(this,A)
      ValueArray = getContainer(this,v);  % robust to change in container
      A = getArray(ValueArray);
      GridSize = getGridSize(this);
      if ~isempty(A) && GridSize(1)>0 && any(GridSize(2:end)>1)
         GridDim = locateGridVar(this,v);
         if ~isempty(GridDim)
            % Replicate to grid size
            % RE: Grid variables have SampleSize=[1 1]
            A = this.utGridFill(A,GridSize,GridDim);
         end
      end
   end

   function A = localSetValue(this,A)
      disp('in set function')
      ValueArray = getContainer(this,v);  % robust to change in container
      try
         ValueArray.setArray(NewValue);
         ValueArray.SampleSize = hdsGetSize(NewValue);
      catch
         warning(sprintf('Value of variable %s could not be written.',ValueArray.Variable.Name))
      end      
      A = [];
   end

end

