%REALIZEMDL Filter realization (Simulink diagram).
%     REALIZEMDL(Hd) automatically generates architecture model of filter
%     Hd in a Simulink subsystem block using individual sum, gain, and
%     delay blocks, according to user-defined specifications.
%
%     REALIZEMDL(Hd, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates
%     the model with parameter/value pairs. Valid properties and values for
%     realizemdl are listed in this table, with the default value noted and
%     descriptions of what the properties do.
%
%     -------------       ---------------      ----------------------------
%     Property Name       Property Values      Description
%     -------------       ---------------      ----------------------------
%     Destination         'current' (default)  Specify whether to add the block
%                         'new'                to your current Simulink model or
%                                              create a new model to contain the
%                                              block.
%                            
%     Blockname           'filter' (default)   Provides the name for the new 
%                                              subsystem block. By default the 
%                                              block is named 'filter'.
%
%     OverwriteBlock      'off' (default)      Specify whether to overwrite an
%                         'on'                 existing block with the same name
%                                              as specified by the Blockname 
%                                              property or create a new block.
%
%     OptimizeZeros       'off' (default)      Specify whether to remove zero-gain
%                         'on'                 blocks.
% 
%     OptimizeOnes        'off' (default)      Specify whether to replace unity-gain
%                         'on'                 blocks with direct connections.
%
%     OptimizeNegOnes     'off' (default)      Specify whether to replace negative
%                         'on'                 unity-gain blocks with a sign
%                                              change at the nearest sum block.
%
%     OptimizeDelayChains 'off' (default)      Specify whether to replace cascaded 
%                         'on'                 chains of delay blocks with a
%                                              single integer delay block to 
%                                              provide an equivalent delay.
%
%    EXAMPLES:
%    [b,a] = butter(4,.4);
%    Hd = dfilt.df1(b,a);
% 
%    %#1 Default syntax:
%    realizemdl(Hd);
% 
%    %#2 Using parameter/value pairs:
%    realizemdl(Hd, 'OverwriteBlock', 'on');
 
%    Author(s): Don Orofino, V. Pellissier
%    Copyright 1988-2002 The MathWorks, Inc.
%    $Revision: 1.1 $  $Date: 2002/10/29 20:38:34 $

% Help for the p-coded REALIZEMDL method of DFILT classes.
