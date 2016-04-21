function sys = append(varargin)
%APPEND  Group IDMODELS by appending their inputs and outputs.
%   Requires the Control Systems Toolbox.
%
%   MOD = APPEND(MOD1,MOD2, ...) produces the aggregate system
% 
%                 [ MOD1  0       ]
%           MOD = [  0   MOD2     ]
%                 [           .   ]
%                 [             . ]
%
%   APPEND concatenates the input and output vectors of the  
%   models MOD1, MOD2,... to produce the resulting model MOD.
%
%   NOTE: APPEND only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%
%   See also FEEDBACK, PARALLEL, SERIES.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:22:15 $

ni = nargin;
nsys = length(varargin);
[ynatot,unatot] = idnamede(varargin);

try
  Nu = 0;Ny = 0;
  for ks = 1:length(varargin)
    syss = varargin{ks};
    [ny,nu] = size(syss);
    Nu = Nu + nu;
    Ny = Ny + ny;
    syss.CovarianceMatrix = [];
varargin{ks} = ss(syss('m'));
end
catch
  error(lasterr)
end
if Nu~=length(unatot)|Ny~=length(ynatot)
  error(['There are overlapping Channel Names in the models to be' ...
	 ' appended.'])
end

try
  SSys = append(varargin{:});
 
catch
  error(lasterr)
end

sys = idss(SSys)
