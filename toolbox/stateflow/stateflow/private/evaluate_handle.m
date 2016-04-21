function hdls = evaulate_handle (ids)
  
  hdls = [];   
  
  try
    for id=[ids]
        hdls = [hdls; find(sfroot, 'Id', id)];
    end
  catch
    % do nothing on error!
  end
  
  

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:57:29 $
