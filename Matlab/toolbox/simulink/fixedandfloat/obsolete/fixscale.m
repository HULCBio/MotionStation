function Scaling = fixscale( FixExp, Slope, Bias );
%FIXSCALE Create VECTOR describing scaling for Fixed Point Block
%
% THIS FUNCTION IS OBSOLETE!!!!!!!!!!!!!!!!!
%
%    When representing "real world" value with a fixed point number
%    it is often desirable to define a scaling
%
%                          FixExp
%    Y          = Slope * 2       * Y        + Bias
%     RealWorld                      Integer
%
%
%    FIXSCALE( FixExp, Slope, Bias )
%
%      Creates a MATLAB structure that defines the scaling
%      and this structure can be passed to a Fixed Point Block
%
%    FIXSCALE( FixExp, Slope )
%
%      Sets the Bias to zero.  
%
%    FIXSCALE( FixExp )
%
%      Sets the Bias to zero and the Slope to plus one. 
%
%    See also SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $  
% $Date: 2002/04/10 19:06:34 $

%
% THIS FUNCTION IS OBSOLETE!!!!!!!!!!!!!!!!!
%
if nargin > 2
	Scaling = [(2^(FixExp))*Slope Bias];
elseif nargin > 1
	Scaling = (2^(FixExp))*Slope;
else
	Scaling = (2^(FixExp));
end
