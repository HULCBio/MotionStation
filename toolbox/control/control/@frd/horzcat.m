function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of LTI models.
%
%   SYS = HORZCAT(SYS1,SYS2,...) performs the concatenation 
%   operation
%         SYS = [SYS1 , SYS2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the LTI models SYS1, SYS2,...
% 
%   See also VERTCAT, LTICAT, LTIMODELS.

%   Author(s): S. Almy, A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2002/11/11 22:21:24 $

% Effect on other properties
% UserData and Notes are deleted

% Remove all empty arguments
ni = nargin;
EmptyModels = logical(zeros(1,ni));
for i=1:ni,
   sizes = size(varargin{i});
   EmptyModels(i) = ~any(sizes(1:2));
end
varargin(EmptyModels) = [];

% Get number of non empty model
nsys = length(varargin);
if nsys==0,
   sys = frd;  return
end

try
   % find first FRD in list
   sysIndex = 1;
   while ~isa(varargin{sysIndex},'frd')
      sysIndex= sysIndex + 1;
   end
   freq = varargin{sysIndex}.Frequency;
   units = varargin{sysIndex}.Units;
   
   % Convert all non FRD to FRD
   for k=1:nsys
      sysi = varargin{k};
      if ~isa(sysi,'frd')
         try
            varargin{k} = frd(sysi,freq,'Units',units);
         catch
            error(sprintf('Error converting input argument %d to FRD format.\n%s',1,lasterr));
         end
      else
         % Check frequency vector compatibility (give priority to units of rad/s)
         [freq,units] = freqcheck(freq,units,sysi.Frequency,sysi.Units);
      end
   end
   
   % Check and harmonize array sizes
   [varargin{:}] = CheckArraySize(varargin{:});
   
   % Initialize output SYS to first input system
   sys = varargin{1};
   sflag = isstatic(sys);  % 1 if static gain
   slti = sys.lti;
   Response = sys.ResponseData;
   Size = size(Response);

   % build responseData field
   for sysIndex = 2:ni
      sysi = varargin{sysIndex};
      if Size(1)~=size(sysi,1)
         error('In [SYS1 , SYS2], SYS1 and SYS2 must have the same number of outputs.')
      end
         
      % Update response data
      Response = cat(2,Response,sysi.ResponseData);
      
      % LTI property management   
      sflagi = isstatic(sysi);
      if sflag || sflagi,
         % Adjust sample time of static gains to prevent clashes
         % RE: static gains are regarded as sample-time free
         [slti,sysi.lti] = sgcheck(slti,sysi.lti,[sflag sflagi]);
      end
      sflag = sflag & sflagi;
      slti = [slti , sysi.lti];
   end
   
   % Create output
   sys.Frequency = freq;
   sys.Units = units;
   sys.ResponseData = Response;
   sys.lti = slti;
   
catch
   rethrow(lasterror);
end
