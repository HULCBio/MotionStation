function sys = stack(dim,varargin)
%STACK  Stack LTI models into LTI array.
%
%   SYS = STACK(ARRAYDIM,SYS1,SYS2,...) produces an array of LTI
%   models SYS by stacking the LTI models SYS1,SYS2,... along
%   the array dimension ARRAYDIM.  All models must have the same 
%   number of inputs and outputs, and the I/O dimensions are not
%   counted as array dimensions.
%
%   For example, if SYS1 and SYS2 are two LTI models with the 
%   same I/O dimensions,
%     * STACK(1,SYS1,SYS2) produces a 2-by-1 LTI array
%     * STACK(2,SYS1,SYS2) produces a 1-by-2 LTI array
%     * STACK(3,SYS1,SYS2) produces a 1-by-1-by-2 LTI array.
%
%   You can also use STACK to concatenate LTI arrays SYS1,SYS2,...
%   along some array dimension ARRAYDIM.
%
%   See also HORZCAT, VERTCAT, APPEND, LTIMODELS.

%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:16:34 $


if ~isa(dim,'double') | ~isequal(size(dim),[1 1]) | dim<=0,
   error('First argument DIM must be a positive integer.')
end


% Offset by I/O and freq dimensions
dim = dim+3;

% find first FRD in list
sysIndex = 1;
while ~isa(varargin{sysIndex},'frd')
   sysIndex= sysIndex + 1;
end
freq = varargin{sysIndex}.Frequency;
units = varargin{sysIndex}.Units;

% Initialize output SYS to first input system
sysi = varargin{1};
if isa(sysi,'double') & ndims(sysi) < 3
   sysi = repmat(sysi,[1 1 length(freq)]);
else
   % give priority to units of rad/s
   try
      [freq,units] = freqcheck(freq,units,sysi.Frequency,sysi.Units);
   catch
   end
end
try
   sys = frd(sysi,freq,'units',units);
catch
   error(sprintf('Error converting SYS%d to FRD format.\n%s',1,lasterr));
end

response = sys.ResponseData;
sizeSys = size(response);
sizeSys(dim:min(dim,end)) = []; % dim doesn't have to match
sflag = isstatic(sys);  % 1 if SYS is a static gain
slti = sys.lti;

% Concatenate remaining input systems
for sysIndex = 2:nargin-1
   sysi = varargin{sysIndex};
   if isa(sysi,'double') & ndims(sysi) < 3
      sysi = repmat(sysi,[1 1 length(freq)]);
   end
   % give priority to units of rad/s
   try
      [freq,units] = freqcheck(freq,units,sysi.Frequency,sysi.Units);
   catch
   end
   try
      sysi = frd(sysi,freq,'units',units);
   catch
      error(sprintf('Error converting SYS%d to FRD format.\n%s',sysIndex,lasterr));
   end
   
   sysResponse = sysi.ResponseData;
   
   sizeSysi = size(sysResponse);
   sizeSysi(dim:min(dim,end)) = []; % dim doesn't have to match
   if ~isequal(sizeSys(1:2),sizeSysi(1:2))
      error('I/O size mismatch.');
   elseif ~isequal(sizeSys,sizeSysi)
      error(sprintf('Sizes of stacked model arrays can only differ only array dimension #%d.',dim-3));
   end
   
   response = cat(dim,response,sysResponse);
   
   % LTI property management   
   sflagi = isstatic(sysi);
   if sflag | sflagi,
      % Adjust sample time of static gains to prevent clashes
      % RE: static gains are regarded as sample-time free
      [slti,sysi.lti] = sgcheck(slti,sysi.lti,[sflag sflagi]);
   end
   sflag = sflag & sflagi;
   try
      newSize = size(response);
      newSize(3:min(3,end)) = [];  % ignore frequency dimension
      slti = stack(dim,slti,sysi.lti,newSize,sizeSysi);
   catch
      rethrow(lasterror)
   end
   
end


% Create output
sys = frd([],[]);
sys.ResponseData = response;
sys.Frequency = freq;
sys.Units = units;
sys.lti = slti;
