%VECTOR_CAN_INTERFACE   MATLAB Vector CAN Hardware API.
%
%  VECTOR_CAN_INTERFACE('command', arg1, arg2, ...)
%
%  Available commands:
%
%  listchannels
%  getchannelname
%  validatechannel
%  setbittiming
%  createmasterport
%  createreadport
%  listports
%  transmit
%  receive
%  isportidactive
%  shutdownport
%  flushtxqueues
%  verbose
%
%  Note on error handling:
%
%  All commands return errorstatus as their first left hand side argument.   
%  errorstatus == 0 for a successful call in to the CAN library.
%  errorstatus == 1 for a non-successful call in to the CAN library.
%
%  An enhancement will add a new command to this interface which will allow the application
%  to query vector_can_interface MEX for the error message associated with the last time
%  errorstatus was returned as 1
%
%  Description of commands:
%
%  -----------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('listchannels')
%
%  Displays the list of channels that vector_can_interface works with.   The channel parameter,
%  channel name, and whether the channel is currently installed are all returned.
%
%  ----------------------------------------------------------------------------
%
%  [errorstatus, channame] = vector_can_interface('getchannelname', channelParam)
%
%  Returns the string channel name associated with a particular channelParam
%
%  --------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('validatechannel', channelParam);
%
%  Takes a hardware channel id parameter (channelParam), and checks that the corresponding 
%  hardware is installed on the system.
%  Use the 'listchannels' option to see the list of available channels.
%
%  ----------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('setbittiming', presc, sjw, tseg1, tseg2, sam, channelParam)
%
%  Registers the desired bit timing parameters for a given channelParam.
%  No hardware is initialised.  The parameters are used when creating
%  master and read ports.   
%
%  See the CAN Drivers (Vector) Simulink Blockset documentation
%  for information on baud rate calculation from the parameters.
%
%  ------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('createmasterport', channelParam, id_string)
%
%  Creates a master port on the given channel param using the bit timing parameters registered
%  for the channel by a call to 'setbittiming'.
%  Id_string is a unique string identifier to identify this port.
% 
%  ---------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('createreadport', master_id_string, [std_ids], [xtd_ids], id_string)
%
%  Creates a read port from the master port (master_id_string)
%  The channel and bit timing configuration associated with the master port are used.
%  Std_ids is a Vector of standard (11 bit) id's used to create a standard id acceptance filter.
%  Xtd_ids is a Vector of extended (29 bit) id's used to create an extended id acceptance filter.
%  Id_string is a unique string identifier to identify this port.
%
%  ------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('listports')
%
%  List detailed information about each of the ports that are currently in existence.
%
%  ------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('transmit', master_id_string, id, extended, [data])
%
%  Transmit a CAN message on the master port specified by master_id_string.   
%  'id' is the Message Identifier.
%  'extended' is either 0 (Standard Frame) or 1 (Extended Frame).
%  '[data]' is an array (max length 8) of data to transmit.
%
%  ------------------------------------------------------------------------------
%
%  [errorstatus, qstatus, id, extended, data, timestamp] = vector_can_interface('receive', id_string)
%
%  Read a CAN message on the port specified by the read port id_string.   
%  Queue status, message id, extended, and [data] are returned to the workspace.
%
%  ------------------------------------------------------------------------------
%
%  [errorstatus, active] = vector_can_interface('isportidactive', id_string)
%
%  Query whether a particular id_string is active.
%  Returns 1 for an active id_string, 0 for an inactive id_string.
%
%  -------------------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('shutdownport', id_string)
%
%  Shutdown the port specified by id_string.
%  This closes the port and future reads / writes to that port will result in error.
%
%  ---------------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('flushtxqueues')
%
%  Flushes all CAN transmit queues.   All messages waiting to be transmitted are
%  sent before this command completes.
%
%  ------------------------------------------------------------------------------
%
%  [errorstatus] = vector_can_interface('verbose')
%
%  Toggles verbose mode on / off.  Default is off.
%
%  -----------------------------------------------------------------------------

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.12.6.2 $
%   $Date: 2004/04/19 01:20:16 $
