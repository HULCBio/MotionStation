function sys = frd(varargin)
%FRD  Creation of or conversion to Frequency Response Data model.
%
%   Frequency Response Data (FRD) models are useful for storing frequency
%   responses of LTI systems, including experimental response data.
%
%  Creation:
%    SYS = FRD(RESPONSE,FREQS) creates an FRD model SYS with response data
%    in RESPONSE at frequency points in FREQS.  The output SYS is an FRD model.
%    See "Data format" below for details.
%
%    SYS = FRD(RESPONSE,FREQS,TS) creates a discrete-time FRD model with
%    sample time TS (set TS = -1 if the sample time is undetermined).
%
%    SYS = FRD creates an empty FRD model.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of FRD models (type LTIPROPS for details).  
%    To make SYS inherit all its LTI properties from an existing LTI model
%    REFSYS, use the syntax SYS = FRD(RESPONSE,FREQS,REFSYS).
%
%  Data format:
%    For SISO models, FREQS is a vector of real frequencies, and RESPONSE is
%    a vector of response data, where RESPONSE(i) represents the system
%    response at FREQS(i).
%
%    For MIMO FRD models with NY outputs, NU inputs, and NF frequency points,
%    RESPONSE is a NY-by-NU-by-NF array where RESPONSE(i,j,k) specifies the
%    frequency response from input j to output i at frequency FREQS(k).
%
%    By default, the units of the frequencies in FREQS are 'rad/s'.
%    Alternately, you can change the units to 'Hz' by modifying the 'Units'
%    property.  Note that changing this property value does not
%    change the numerical frequency values.  Use CHGUNITS(SYS,UNITS) to change
%    the frequency units of an FRD model, performing the necessary conversion.
%
%  Arrays of FRD models:
%    You can create arrays of FRD models by using an ND array for RESPONSE
%    above.  For example, if RESPONSE is an array of size [NY NU NF 3 4], then 
%       SYS = FRD(RESPONSE,FREQS) 
%    creates the 3-by-4 array of FRD models, where
%       SYS(:,:,k,m) = FRD(RESPONSE(:,:,:,k,m),FREQS),  k=1:3,  m=1:4.
%    Each of these FRD models has NY outputs and NU inputs, and holds data at
%    each frequency point in FREQS.
%
%  Conversion:
%    SYS = FRD(SYS,FREQS,'Units',UNITS) converts an arbitrary LTI model SYS to
%    the FRD model representation, generating the system response at each
%    frequency in FREQS.  UNITS specifies the units of the frequencies in FREQS,
%    which may be 'rad/s' or 'Hz', and will default to 'rad/s' if the last
%    two arguments are omitted.  The result is an FRD model.
%
%  See also LTIMODELS, SET, GET, FRDATA, CHGUNITS, LTIPROPS, TF, ZPK, SS.

%       Author(s): S. Almy, A. Potvin, P. Gahinet
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.11 $  $Date: 2002/04/10 06:17:52 $


ni = nargin;
if ni & isa(varargin{1},'frd'),
   % FRD(SYS) where SYS is an FRD object or a child of FRD: leave it untouched,
   % even if FREQS ~= sys.Frequency
   sys = varargin{1};
   if ni>4 | ( ni>2 & ~strncmpi(varargin{3},'un',2)  )
      error('Use SET to modify the properties of FRD objects.');
   elseif isa(varargin{2},'double')
      % FRD(FRDSYS,W)
      try
         varargin{2} = varargin{2}(:);
         if ni > 3
            freqcheck(sys.Frequency,sys.Units,varargin{2},varargin{4});
            sys.Units = varargin{4};
         else
            freqcheck(sys.Frequency,sys.Units,varargin{2},sys.Units);
         end
         sys.Frequency = varargin{2};
         try
            sys = frdcheck(sys,1);
         catch
            rethrow(lasterror);
         end
      catch
         error('In FRD(SYS,FREQS), FREQS must match FRD frequencies when SYS is an FRD model.')
      end
   end
   return
end

% Define default property values
superiorto('double','ss','zpk','tf')
sys = struct('Frequency',zeros(0,1),'ResponseData',zeros(0,0,0),'Units','rad/s');
% ( valid units entries - 'rad/s','Hz' )

% Disect input list
DoubleInputs = 0;
LtiInput = 0;
PVstart = 0;
while DoubleInputs<ni & PVstart==0,
  nextarg = varargin{DoubleInputs+1};
  if isa(nextarg,'lti'),
     LtiInput = DoubleInputs+1;
     PVstart = DoubleInputs+2;
  elseif ischar(nextarg) | (~isempty(nextarg) & iscellstr(nextarg)),
     PVstart = DoubleInputs+1;  
  else
     DoubleInputs = DoubleInputs+1;
  end
end

% Handle bad calls
if PVstart==1,
   if ni==1,
     % Bad conversion
     error('Conversion from string to FRD is not possible.')
   else
     error('First input must contain only numerical data.');
   end
elseif DoubleInputs>3
   error('Too many numerical inputs.');
elseif (DoubleInputs==3 & LtiInput),
   error('Possible sample time conflict.  Do not specify both sample time and LTISYS.');
end


% Process numerical data 
valueChange = 0;
switch DoubleInputs,
case 0
   if ni, error('Too many LTI arguments or missing numerical data.'); end
case 1
   error('Need to specify 2 or 3 numerical inputs.');
otherwise
   % FREQS and RESPONSE specified
   sys.ResponseData = varargin{1};
   sys.Frequency= varargin{2};    
   sys.Units = 'rad/s';  % set to rad/s now, allow PV pair to change it later
   valueChange = 3;
end


% Check consistency of FREQS, RESPONSE - put in proper format
if ni>0,
   try 
      sys = frdcheck(sys,valueChange);
   catch
      rethrow(lasterror)
   end
end

% Create LTI parent
Ny = size(sys.ResponseData,1);
Nu = size(sys.ResponseData,2);
if LtiInput,
   L = varargin{LtiInput};
   if isa(L,'frd'),
      L = L.lti;
   end
   Ts = getst(L);
elseif DoubleInputs<=2,
   % Default parent LTI with Ts = 0
   L = lti(Ny,Nu);
   Ts = 0;
else
   % Discrete FRD 
   Ts = varargin{3};
   if isempty(Ts),  
      Ts = -1;  
   elseif ~isreal(Ts) | ~isfinite(Ts) | length(Ts)~=1,
      error('Sample time T must be a real number.');
   elseif Ts<0 & Ts~=-1,
      error('Negative sample time not allowed (except Ts=-1 to mean unspecified).');
   end
   L = lti(Ny,Nu,Ts);
end

% FRD is a subclass of LTI
sys = class(sys,'frd',L);

% Set PV pairs
if (PVstart>0) & (PVstart<=ni),
   try
      set(sys,'Frequency',sys.Frequency,varargin{PVstart:ni})
   catch
      rethrow(lasterror)
   end
end
