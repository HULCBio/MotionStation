function Scaling = fixslope( Slope, Bias );
%FIXSLOPE Create VECTOR describing scaling for Fixed Point Block
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
%    FIXSLOPE( Slope, Bias )
%
%      Creates a MATLAB structure that defines the scaling with
%      FixExp = 0;
%      This structure can be passed to a Fixed Point Block
%
%    FIXSLOPE( Slope )
%
%      Sets the Bias to zero.  
%
%    See also FIXRADIX, SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 19:06:31 $

%
% THIS FUNCTION IS OBSOLETE!!!!!!!!!!!!!!!!!
%
if nargin > 1
	Scaling = [Slope, Bias];
else
	Scaling = Slope;
end

