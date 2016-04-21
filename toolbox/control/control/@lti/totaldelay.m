function Tdio = totaldelay(sys)
%TOTALDELAY  Total time delays between inputs and outputs.
%
%   TD = TOTALDELAY(SYS) returns the total I/O delays TD for the 
%   LTI model SYS.  The matrix TD combines contributions from
%   the INPUTDELAY, OUTPUTDELAY, and IODELAYMATRIX properties, 
%   (see LTIPROPS for details on these properties).
%
%   Delays are expressed in seconds for continuous-time models, 
%   and as integer multiples of the sample period for discrete-time 
%   models (to obtain the delay times in seconds, multiply TD by 
%   the sample time SYS.TS).
%
%   See also HASDELAY, DELAY2Z, LTIPROPS.

%   Author(s):  P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:47:34 $

Tdio = sys.ioDelay;
ny = size(Tdio,1);
nu = size(Tdio,2);

if max([ndims(Tdio),ndims(sys.InputDelay),ndims(sys.OutputDelay)])==2,
   % Fast 2D operation
   id = sys.InputDelay';
   Tdio = Tdio + id(ones(ny,1),:) + sys.OutputDelay(:,ones(nu,1));
   
else
   % General case (LTI array with varying delay)
   id = permute(sys.InputDelay,[2 1 3:ndims(sys.InputDelay)]);
   
   % Add input delays
   Tdio = ndops('add',Tdio,repmat(id,[ny 1]));
   
   % Add output delays
   Tdio = ndops('add',Tdio,repmat(sys.OutputDelay,[1 nu]));
end

