function can_msg_id_check(id, msg_type)
%CAN_MSG_ID_CHECK checks for a valid CAN message identifier
%  Checks if the specified message identifier and message type are valid
%
%  CAN_MSG_ID_CHECK(ID, MSG_TYPE) takes a numeric identifier ID, e.g. '51' or
%  hex2dec('100') and MSG_TYPE, which must be either 1 for Standard (11-bit 
%  identifier) or 2 for Extended (29-bit identifier). If ID is 
%  is an integer in the valid range the function returns successfully.
%  If any of the checks fails an error is generated.
%
%  See also 

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:21:41 $
  
  if ischar(id)
    error(['The CAN message identifier must be specified as a number, not a string'])
  end
  
  if length(id) > 1
    error(['The CAN message identifier cannot be a vector'])
  end
    
  switch msg_type
   case 1 % 'Standard (11-bit identifier)'
    if floor(id)~=id | id<0 | id>=2^11
      error([num2str(id) ' is an invalid 11-bit CAN message identifer'])
    end
      case 2 % 'Extended (29-bit identifier)'
       if floor(id)~=id | id<0 | id>=2^29
	 error([num2str(id) ' is an invalid 29-bit CAN message identifer'])
       end
   otherwise
    error(['Unrecognized message type ' num2str(msg_type)])
  end
     
     