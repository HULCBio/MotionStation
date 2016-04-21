function Scaling = fixradix( FixExp );
%FIXRADIX Create VECTOR describing scaling for Fixed Point Block
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
%    FIXRADIX( FixExp )
%
%      Creates a MATLAB structure that defines the scaling with
%      Slope = 1
%      Bias  = 0
%      This structure can be passed to a Fixed Point Block
%
%    See also FIXSLOPE, SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 19:06:37 $

%
% THIS FUNCTION IS OBSOLETE!!!!!!!!!!!!!!!!!
%
Scaling = (2^(FixExp));
