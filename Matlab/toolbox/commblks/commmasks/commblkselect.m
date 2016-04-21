function commblkselect(elements)
%  Communication blockset helper function. This function is called to check 
%  puncture and insert zero block parameters.
  
%  Copyright 1996-2002 The MathWorks, Inc.
%  $Revision: 1.6 $  $Date: 2002/03/24 02:02:04 $

  if ~isnumeric(elements) | isempty(elements)     | ...
     isequal(isreal(elements), 0)                 | ...
     ~isequal(double(elements~=0), elements) | ...
     isequal(sum(elements(:)), 0)
    
    error(['Invalid parameter specified. The parameter must be a ' ...
	  'nonempty binary vector. In addition, at least one of its '...
          'elements must be nonzero.']);
  end
 
  
  
  
  
