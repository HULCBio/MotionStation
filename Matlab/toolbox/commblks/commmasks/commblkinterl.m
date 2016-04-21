function commblkinterl(elements)
%  Communication blockset helper function. This function is called to check 
%  interleaver and deinterleaver block parameters.

%  Copyright 1996-2002 The MathWorks, Inc.
%  $Revision: 1.5 $  $Date: 2002/03/24 02:01:40 $

  if  ~isnumeric(elements) | isempty(elements),
    error(['Invalid Elements specified. Elements must be a nonempty ' ...
	  'integer vector.']);
  end
  uWidth   = length(elements);  
  yWidth   = uWidth;  
  tmp      = [1:uWidth];      
  if ~isequal(tmp,sort(elements(:)'))  
    error(['Invalid Elements specified. Elements must be a nonempty ' ...
	  'positive integer vector with unique elements.']);
  end    



