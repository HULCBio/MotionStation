function [channel_name] = vector_channel_name(channel_param)
%VECTOR_CHANNEL_NAME calculates the channel name from the channel parameter
%   Called from the mask initialization for Vector configuration, transmit
%   and receive blocks
%
%   channel_name = VECTOR_CHANNEL_NAME(channel_param) returns the
%   returns the channel_name calculated from channel_param value returned
%   by the dialog box pop-down

%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $
%   $Date: 2004/04/19 01:20:17 $


% work out  a channel name for display.
  switch channel_param
   case 1,
    channel_name = 'Virtual 1';
   case 2,
    channel_name = 'Virtual 2';
   case 3,
    channel_name = 'CanAc2Pci 1';
   case 4,
    channel_name = 'CanAc2Pci 2';
   case 5,
    channel_name = 'CanAc2 1';
   case 6,
    channel_name = 'CanAc2 2';
   case 7,
    channel_name = 'CanCardX 1';
   case 8,
    channel_name = 'CanCardX 2';
   case 9,
    channel_name = 'CanPari';
   case 10,
    channel_name = 'None selected';
   otherwise
    error(sprintf('Invalid value for channel_param: %s',channel_param))
  end