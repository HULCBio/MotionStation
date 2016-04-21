function fdahoststruct = fdaregisterhost
%FDAREGISTERHOST Registers the Signal Processing Blockset as the Host of an FDATool session.
%   STRUCT = FDAREGISTERHOST Returns the proper FDATool host structure to 
%   register the Signal Processing Blockset as the Host of FDATool.


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/12 23:07:51 $ 

fdahoststruct.name = 'Signal Processing Blockset';
fdahoststruct.version = 1.0;

% SETTITLE is used later when we have the name to the block.
fdahoststruct.subtitle = '';
fdahoststruct.figtitle = 'Block Parameters:';

% [EOF]
