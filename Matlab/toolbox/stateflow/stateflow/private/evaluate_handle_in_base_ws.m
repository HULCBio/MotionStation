function evaluate_handle_in_base_ws (id)

   try
       cmd = sprintf('sf(''Private'', ''evaluate_handle'', %d)', id);
       evalin('base', cmd);
   catch
       % do nothing
   end

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:57:30 $
