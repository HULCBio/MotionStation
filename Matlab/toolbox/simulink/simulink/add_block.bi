function [varargout] = add_block(varargin)
%ADD_BLOCK Add a block to a Simulink system.
%   ADD_BLOCK('SRC','DEST') copies the block with full path name 'SRC' to a
%   new block with full path name 'DEST'.  The block parameters of the new
%   block are identical to those of the original.  The name 'built-in' can
%   be used as a source system name for all Simulink built-in blocks.
%   
%   ADD_BLOCK('SRC','DEST','PARAMETER1',VALUE1,...) creates a copy as above
%   in which the named parameters have the specified values.  Any additional
%   arguments must occur in parameter-value pairs.
%   
%   ADD_BLOCK('SRC','DEST','MAKENAMEUNIQUE','ON','PARAMETER_NAME1',VALUE1,...)
%   creates a copy as above and if a block of full path name 'DEST' already
%   exists, the name of the new block is changed such that it is made
%   unique.
%
%   ADD_BLOCK('SRC','DEST','COPYOPTION','DUPLICATE','PARAMETER_NAME1',VALUE1,...)
%   works for INPORT blocks and it creates a copy with the same port number
%   as the 'SRC' block.
%
%   Examples:
%   
%       add_block('simulink/Sinks/Scope','engine/timing/Scope1')
%   
%   copies the Scope block from the Sinks subsystem of the simulink system
%   to a block named 'Scope1' in the timing subsystem of the engine system.
%   
%       add_block('built-in/SubSystem','F14/controller') 
%   
%   creates a new subsystem named 'controller' in the F14 system.
%   
%       add_block('built-in/Gain','mymodel/volume','Gain','4')
%   
%   copies the built-in Gain block to a block named 'volume' in the mymodel
%   system, and assigns the Gain parameter a value of 4. 
%
%       block = add_block('vdp/Mu', 'vdp/Mu', 'MakeNameUnique', 'on')
%
%   copies the block name 'Mu' in 'vdp' and create a copy. Since the 'Mu'
%   block already exists, the new block is named 'Mu1'. The default is
%   'off'.
%
%       add_block('vdp/Inport', 'vdp/Inport2', 'CopyOption', 'duplicate')
%
%   creates a new block 'Inport2' that shares the same port number as the
%   'Inport' block in 'vdp'. The default is 'copy'.
%
%   See also DELETE_BLOCK, SET_PARAM.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.16.2.3 $
%   Built-in function.

if nargout == 0
  builtin('add_block', varargin{:});
else
  [varargout{1:nargout}] = builtin('add_block', varargin{:});
end
