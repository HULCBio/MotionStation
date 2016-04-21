function sys = append(varargin)
%APPEND  Group LTI models by appending their inputs and outputs.
%
%   SYS = APPEND(SYS1,SYS2, ...) produces the aggregate system
% 
%                 [ SYS1  0       ]
%           SYS = [  0   SYS2     ]
%                 [           .   ]
%                 [             . ]
%
%   APPEND concatenates the input and output vectors of the LTI
%   models SYS1, SYS2,... to produce the resulting model SYS.
%
%   If SYS1,SYS2,... are arrays of LTI models, APPEND returns an LTI
%   array SYS of the same size where 
%      SYS(:,:,k) = APPEND(SYS1(:,:,k),SYS2(:,:,k),...) .
%
%   See also SERIES, PARALLEL, FEEDBACK, LTIMODELS.

%   Author(s): S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2002/11/11 22:21:05 $

ni = nargin;

try
   % find first FRD in list
   sysIndex = 1;
   while ~isa(varargin{sysIndex},'frd')
      sysIndex= sysIndex + 1;
   end
   freq = varargin{sysIndex}.Frequency;
   units = varargin{sysIndex}.Units;
   
   % Convert all non FRD to FRD
   for k=1:ni
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
   indices = repmat({':'},[1 length(Size)]);
   
   % build responseData field
   for sysIndex = 2:ni
      sysi = varargin{sysIndex};
      iResponse = sysi.ResponseData;
      Response = cat(1,cat(2,Response,zeros([size(Response,1),size(iResponse,2),Size(3:end)])), ...
         cat(2,zeros([size(iResponse,1),size(Response,2),Size(3:end)]),iResponse(indices{:})));
      
      % LTI property management   
      sflagi = isstatic(sysi);
      if sflag || sflagi,
         % Adjust sample time of static gains to prevent clashes
         % RE: static gains are regarded as sample-time free
         [slti,sysi.lti] = sgcheck(slti,sysi.lti,[sflag sflagi]);
      end
      sflag = sflag & sflagi;
      slti = append(slti,sysi.lti);   
   end
   
   % Create output
   sys.Frequency = freq;
   sys.Units = units;
   sys.ResponseData = Response;
   sys.lti = slti;
   
catch
   rethrow(lasterror);
end
