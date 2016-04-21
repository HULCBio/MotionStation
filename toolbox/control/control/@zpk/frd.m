function FRDsys = frd(varargin)
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

%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $  $Date: 2002/04/10 06:12:51 $

% Effect on other properties
% Keep all LTI parent fields

sys = varargin{1};
nin = nargin;
factor = 1;

if ~isa(sys,'zpk'),
  % Handle syntax FRD(freq,response,sys) with sys of class SS/TF/ZPK
  nlti = 0;
  for index=1:length(varargin),
     if isa(varargin{index},'lti'),
        nlti = nlti + 1;   ilti = index;
     end
  end
  if nlti>1,
     error('Cannot call FRD with multiple LTI arguments.');
  else
     % Replace sys by sys.lti and call constructor frd/frd.m
     varargin{ilti} = varargin{ilti}.lti;
     FRDsys = frd(varargin{:});
     return
  end
elseif nin < 2,
   error('Conversion to FRD requires at least 2 input arguments.');
elseif nin < 3,
   units = 'rad/s';
elseif nin == 4 & strncmpi(varargin{3},'un',2)
   units = varargin{4};
   if strncmp(lower(units),'h',1)
      factor = 2*pi;
   end
else
   error('Incorrect syntax for conversion to FRD.  Try FRD(SYS,FREQ,''Units'',UNITS).');
end

frequency = varargin{2};

if ~isa(frequency,'double') | ~all(isreal(frequency)) | min(size(frequency))>1 | ndims(frequency)>2
   error('FREQS must be a vector of real frequencies.');
end

% Generate response data
[ny, nu] = size(sys);
sysLTI = sys.lti; % includes time delays
% Leave delays out for freq. resp. computation
sys.lti = pvset(sys.lti,'ioDelay',zeros(ny,nu),...
   'OutputDelay',zeros(ny,1),'InputDelay',zeros(nu,1));
response = freqresp(sys,frequency*factor);

% Create FRD model
FRDsys = frd(response,frequency,sysLTI);
set(FRDsys,'Units',units,'Frequency',FRDsys.Frequency);
