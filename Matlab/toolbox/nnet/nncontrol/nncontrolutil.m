function varargout=nncontrolutil(command,varargin)
%NNCONTROLUTIL Execute intermediate calls to private function under Simulink for NNcontrol toolbox.
%
%  Synopsis
%
%    varargout=nncontrolutil(command,varargin)
%
%  command  = Function called.
%  varargin = All the input parameters for the function in command.
%  
%  varargout = All the output parameters for the function in command.
%

% Orlando De Jesus, Martin Hagan, 2-27-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:12:13 $

n_par=nargout;
if n_par==0
   feval(command,varargin{:});
else
   varargout=cell(1,n_par);
   [varargout{:}]=feval(command,varargin{:});
end

command=command;
