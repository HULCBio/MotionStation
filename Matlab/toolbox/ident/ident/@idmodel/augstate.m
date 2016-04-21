function sys = augstate(sys)
%AUGSTATE  Appends states to the outputs of a state-space model.
%   Requires the Control Systems Toolbox.
%
%   AMOD = AUGSTATE(MOD)  appends the states to the outputs of 
%   the state-space model MOD given as an IDSS or IDGREY object.  
%   The resulting model AMOD is an IDSS object, describing the
%   following system:
%      .                       .
%      x  = A x + B u    
%
%     |y| = [C] x + [D] u
%     |x|   [I]     [0]
%
%   This command is useful to close the loop on a full-state
%   feedback gain  u = Kx.  After preparing the plant with
%   AUGSTATE,  you can use the FEEDBACK command to derive the 
%   closed-loop model.
%
%   Covariance information is lost in the transformation.
%
%   The noise inputs are first eliminated. To include those,
%   first convert them to measured inputs by NOISECNV.


%       Copyright 1986-2001 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2001/04/06 14:22:15 $

if ~(isa(sys,'idss')|isa(sys,'idgrey'))
  error('AUGSTATE applies only to IDGREY and IDSS models.')
end
try
sys1 = ss(sys('m'));
nx = size(sys,'nx');
catch
  error(lasterr)
  end
sys1 = augstate(sys1);
sys = idss(sys1);
