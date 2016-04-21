function vector_can_msg_ids_check(ids, msg_type)
%VECTOR_CAN_MSG_IDS_CHECK checks for valid CAN message identifiers
%  Checks if the specified message identifiers and message type are valid
%
%  VECTOR_CAN_MSG_IDS_CHECK(IDS, MSG_TYPE) takes numeric identifiers IDS, e.g. [51 12] or
%  hex2dec('100') and MSG_TYPE, which must be either 1 for Standard (11-bit 
%  identifier) or 2 for Extended (29-bit identifier). If IDS are 
%  integers in the valid range the function returns successfully.
%  If any of the checks fails an error is generated.
%
%  See also 

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.3 $
%   $Date: 2002/08/23 11:47:06 $
  if ischar(ids)
    error(['The CAN message identifiers must be specified as numbers, not as strings'])
  end
    
  % vectorized check
  switch msg_type
   case 1 % 'Standard (11-bit identifier)'
    if any(floor(ids)~=ids) | any(ids<0) | any(ids>=2^11)
      str = num2str(ids);
      % remove double whitespace
      indices = findstr(str, '  ');
      str(indices) = [];
      error(['[' str '] is an invalid vector of 11-bit CAN message identifiers'])
    end
      case 2 % 'Extended (29-bit identifier)'
       if any(floor(ids)~=ids) | any(ids<0) | any(ids>=2^29)
           str = num2str(ids);
           % remove double whitespace
           indices = findstr(str, '  ');
           str(indices) = [];
           error(['[' str '] is an invalid vector of 29-bit CAN message identifiers'])
       end
   otherwise
    error(['Unrecognized message type ' num2str(msg_type)])
  end   