function obj = cfit(model,varargin)
%CFIT Construct CFIT object.
%   CFIT(MODEL,COEFF1,COEFF2,COEFF3,...) constructs a CFIT 
%   object from the MODEL and the COEFF values.
%
%   You should use the FIT command to create a CFIT object.  You
%   should not call the CFIT constructor directly.
%
%   Example:
%     ftobj = fittype('a*x^2+b*exp(x)');
%     cfobj = fit(x,y,ftobj);
%
%   See also FIT.

%   Possible parameters:
%   'sse'         sum squared of error
%   'dfe'         degrees of freedom of error
%   'Jacobian'    Jacobian matrix of MODEL
%   'R'           R factor matrix of QR decomposition of Jacobian
%   'meanx'       mean of xdata used to normalize data before fitting
%   'stdx'        std of xdata used to normalize data before fitting
%   'activebounds' boolean vector indicating which coeffs are at
%                  their bounds (may be empty if none are active)
%   'xlim'        min and max of x range of data used in fit
%   
%   Note: 'Jacobian' and 'R' are redundant parameters in that only one
%         is needed. 
%
%   Examples:
%     m = fittype('a*x+b');
%     f = cfit(m,1,2);
%     m = fittype('a*x^2+b*exp(n*x)','prob','n');
%     f = cfit(m,pi,10.3,3);
%    

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.19.2.2 $  $Date: 2004/02/01 21:39:03 $

% CFIT Object fields
% .coeffValues cell array of coefficient values
% .probValues  cell array of problem dependent parameter values 
% .sse         sum squared of error
% .dfe         degrees of freedom of error
% .rinv        inverse of R factor of QR decomposition of Jacobian
% .meanx       mean of the xdata used to center the data
% .stdx        std of the xdata used to scale the data
% .version     object version
% .fittype     model
% .xlim        limits of x data used in the fit
%
% FITTYPE Object fields
% .expr        string containing function definition
% .feval       flag indicating if model is evaluated using feval or eval
% .args        string matrix containing formal parameter names
% .isEmpty     flag indicating model called with no arguments
% .numArgs     number of formal parameters
% .version     Class version number
% .assignData  eval string to assign inputs to independent (data) variable
% .assignCoeff eval string to assign inputs to coefficients
% .assignProb  eval string to assign inputs to problem dependent parameters
% .indep       string matrix of independent parameter names
% .depen       string matrix of dependent parameter names
% .coeff       string matrix of coefficient parameter names
% .prob        string matrix of problem parameter names
% .version

obj.coeffValues = {};
obj.probValues = {};
obj.sse = [];
obj.dfe = [];
obj.rinv = [];
obj.meanx = 0;
obj.stdx = 1;
obj.version = 1.0;
obj.activebounds = [];
obj.xlim = [];

if (nargin == 0)
    % Construct default fittype object
    model = fittype; 
    obj = class(obj, 'cfit',model);
    return;
elseif (nargin == 1)
    if isa(model,'cfit')
        obj = model;
        return
    elseif ~isa(model,'fittype')
        error('curvefit:cfit:invalidCall', ...
              'Invalid call to CFIT.')
    end
elseif (nargin > 1)
   numCoeffs = size(coeffnames(model),1);
   numProbs = size(probnames(model),1);
   if (nargin < numCoeffs+numProbs+1)
       error('curvefit:cfit:moreParamsNeeded', ...
             'Not enough parameters input to fit the model.');
   end
   
   obj.coeffValues = varargin(1:numCoeffs);
   obj.probValues = varargin(numCoeffs+(1:numProbs));
   varargin(1:(numCoeffs+numProbs)) = [];
   
   % We've already warned about conditioning during fit, 
   % so turn off  warning so "\" doesn't warn below.
   ws = warning('off', 'all'); 
   % There may be additional option name/values pairs
   R = [];
   Jacobian = [];
   activebounds = [];
   while length(varargin)>1
       switch varargin{1}
       case 'sse',
           obj.sse = varargin{2};
       case 'dfe',
           obj.dfe = varargin{2};
       case 'R',
           R = varargin{2};
       case 'Jacobian',
           Jacobian = varargin{2};
       case 'activebounds',
           tmp = varargin{2};
           if isstruct(tmp)
              activebounds = (tmp.lower | tmp.upper);
           else
              activebounds = [];
           end
       case 'meanx'
           obj.meanx = varargin{2};
       case 'stdx'
           obj.stdx = varargin{2};
       case 'xlim'
           obj.xlim = varargin{2};
       otherwise
           error('curvefit:cfit:invalidArg', ...
                 '"%s" is not a valid argument.',varargin{1});
       end
       varargin(1:2) = [];      
   end
   warning(ws);

   % Get inv(R) one way or another
   if isempty(R) && ~isempty(Jacobian)
      if sum(activebounds)>0
         Jacobian = Jacobian(:,~activebounds);
      end
      [Q,R] = qr(Jacobian,0);
   end
   if size(R,1)==size(R,2)
      ws = warning('off', 'all');
      obj.rinv = R \ eye(length(R));
      warning(ws);
   end
   if isempty(activebounds)
      activebounds = zeros(numCoeffs,1);
   end
   obj.activebounds = activebounds;

   if length(varargin)>0
       error('curvefit:cfit:invalidLastArg', ...
             'Last argument is not part of a name/value pair.');
   end
end

obj = class(obj, 'cfit',model);
