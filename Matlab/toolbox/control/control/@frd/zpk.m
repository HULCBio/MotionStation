function ZPKsys = zpk(varargin)
%ZPK  Create zero-pole-gain models or convert to zero-pole-gain format.
%
%  Creation:
%    SYS = ZPK(Z,P,K) creates a continuous-time zero-pole-gain (ZPK) 
%    model SYS with zeros Z, poles P, and gains K.  The output SYS is 
%    a ZPK object.  
%
%    SYS = ZPK(Z,P,K,Ts) creates a discrete-time ZPK model with sample
%    time Ts (set Ts=-1 if the sample time is undetermined).
%
%    S = ZPK('s') specifies H(s) = s (Laplace variable).
%    Z = ZPK('z',TS) specifies H(z) = z with sample time TS.
%    You can then specify ZPK models as rational expressions in 
%    S or Z, e.g.,
%       z = zpk('z',0.1);  H = (z+.1)*(z+.2)/(z^2+.6*z+.09)
%
%    SYS = ZPK creates an empty zero-pole-gain model.
%    SYS = ZPK(D) specifies a static gain matrix D.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of ZPK models (see LTIPROPS for 
%    details).  To make SYS inherit all its LTI properties from an 
%    existing LTI model REFSYS, use the syntax SYS = ZPK(Z,P,K,REFSYS).
%
%  Data format:
%    For SISO models, Z and P are the vectors of zeros and poles (set  
%    Z=[] if no zeros) and K is the scalar gain.
%
%    For MIMO systems with NY outputs and NU inputs, 
%      * Z and P are NY-by-NU cell arrays where Z{i,j} and P{i,j}  
%        specify the zeros and poles of the transfer function from
%        input j to output i
%      * K is the 2D matrix of gains for each I/O channel.  
%    For example,
%       H = ZPK( {[];[2 3]} , {1;[0 -1]} , [-5;1] )
%    specifies the two-output, one-input ZPK model
%       [    -5 /(s-1)      ]
%       [ (s-2)(s-3)/s(s+1) ] 
%
%  Arrays of zero-pole-gain models:
%    You can create arrays of ZPK models by using ND cell arrays for Z,P 
%    above, and an ND array for K.  For example, if Z,P,K are 3D arrays 
%    of size [NY NU 5], then 
%       SYS = ZPK(Z,P,K) 
%    creates the 5-by-1 array of ZPK models
%       SYS(:,:,m) = ZPK(Z(:,:,m),P(:,:,m),K(:,:,m)),   m=1:5.
%    Each of these models has NY outputs and NU inputs.
%
%    To pre-allocate an array of zero ZPK models with NY outputs and NU 
%    inputs, use the syntax
%       SYS = ZPK(ZEROS([NY NU k1 k2...])) .
%
%  Conversion:
%    SYS = ZPK(SYS) converts an arbitrary LTI model SYS to the ZPK 
%    representation. The result is a ZPK object.  
%
%    SYS = ZPK(SYS,'inv') uses a fast algorithm for conversion from state
%    space to ZPK, but is typically less accurate for high-order systems.
%
%  See also LTIMODELS, SET, GET, ZPKDATA, SUBSREF, SUBSASGN, LTIPROPS, TF, SS.

%       Author(s): A. Potvin, 3-1-94
%       Revised: P. Gahinet, 4-1-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $  $Date: 2002/04/10 06:16:11 $

% Effect on other properties
% Keep all LTI parent fields

if isa(varargin{1},'frd')
   % Error out of ZPK(FRD) case
   error('Unable to convert FRD model to ZPK format.');
else
   % Handle syntax zpk(z,p,k,sys) with sys of class FRD
   nlti = 0;
   for i=1:length(varargin),
      if isa(varargin{i},'lti')
         nlti = nlti + 1;   ilti = i;
      end
   end
   if nlti>1
      error('Cannot call ZPK with several LTI arguments.');
   else
      % Replace sys by sys.lti and call constructor zpk/zpk.m
      varargin{ilti} = varargin{ilti}.lti;
      ZPKsys = zpk(varargin{:});
   end
end
