function [varargout] = sim(varargin)
%SIM Simulate a Simulink model
%   SIM('model') will simulate your Simulink model using all simulation
%   parameter dialog settings including Workspace I/O options.
%
%   The SIM command also takes the following parameters. By default
%   time, state, and output are saved to the specified left hand side
%   arguments unless OPTIONS overrides this. If there are no left hand side
%   arguments, then the simulation parameters dialog Workspace I/O settings
%   are used to specify what data to log.
%
%   [T,X,Y]         = SIM('model',TIMESPAN,OPTIONS,UT)
%   [T,X,Y1,...,Yn] = SIM('model',TIMESPAN,OPTIONS,UT)
%
%       T            : Returned time vector.
%       X            : Returned state in matrix or structure format. 
%                      The state matrix contains continuous states followed by 
%                      discrete states. 
%       Y            : Returned output in matrix or structure format. 
%                      For block diagram models this contains all root-level 
%                      outport blocks.
%       Y1,...,Yn    : Can only be specified for block diagram models, where n
%                      must be the number of root-level outport blocks. Each
%                      outport will be returned in the Y1,...,Yn variables.
%
%       'model'      : Name of a block diagram model.
%       TIMESPAN     : One of:
%                        TFinal,
%                        [TStart TFinal], or
%                        [TStart OutputTimes TFinal].
%                      OutputTimes are time points which will be returned in
%                      T, but in general T will include additional time points.
%       OPTIONS      : Optional simulation parameters. This is a structure
%                      created with SIMSET using name value pairs.
%       UT           : Optional extern input.  UT = [T, U1, ... Un]
%                      where T = [t1, ..., tm]' or UT is a string containing a
%                      function u=UT(t) evaluated at each time step.  For
%                      table inputs, the input to the model is interpolated
%                      from UT.
%
%   Specifying any right hand side argument to SIM as the empty matrix, [],
%   will cause the default for the argument to be used.
%
%   Only the first parameter is required. All defaults will be taken from the
%   block diagram, including unspecified options.  Any optional arguments
%   specified will override the settings in the block diagram.
%
%   See also SLDEBUG, SIMSET.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.19.2.2 $
%   Built-in function.

if nargout == 0
  builtin('sim', varargin{:});
else
  [varargout{1:nargout}] = builtin('sim', varargin{:});
end
