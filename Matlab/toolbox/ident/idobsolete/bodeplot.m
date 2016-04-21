function bodeplot(varargin)
%BODEPLOT Plots the Bode diagram of a transfer function or spectrum.
%   OBSOLETE function. Use BODE instead. Se HELP IDMODEL/BODE.
 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:44 $

if nargout == 0
   bodeaux(1,varargin{:});
elseif nargout <= 3
   [amp,phas,w] = bodeaux(1,varargin{:});
else
   [amp,phas,w,sdamp,sdphas] = bodeaux(1,varargin{:});
end
 