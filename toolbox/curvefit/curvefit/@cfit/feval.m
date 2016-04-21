function varargout = feval(varargin)
%FEVAL  FEVAL a CFIT object.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.11.2.2 $  $Date: 2004/02/01 21:39:10 $


obj = varargin{1};
if ~isa(obj,'cfit')
    % If any of the elements in varargin are CFIT objects, then the
    %  overloaded CFIT feval is called even if the first argument
    %  is a string.  In this case, we call the builtin feval.
    [varargout{1:max(1,nargout)}] = builtin('feval',varargin{:});
    return
end

inputs = varargin(2:end);
if (length(inputs) < 1)
    error('curvefit:cfit:feval:notEnoughInputs', ...
          'Not enough inputs to CFIT/FEVAL.');
elseif (length(inputs) > 1)
    error('curvefit:cfit:feval:tooManyInputs', ...
          'Too many inputs to CFIT/FEVAL.');
end
xdata = varargin{2};

% quad passes row vectors, so need to make sure xdata is column
xdata = (xdata(:)-obj.meanx)/obj.stdx;  % In case it was normalized
try
    [varargout{1:max(1,nargout)}] = feval(obj.fittype, obj.coeffValues{:},...
        obj.probValues{:}, xdata);
catch
    error('curvefit:cfit:feval:evaluationError', ... 
          'Error while trying to evaluate CFIT model: %s:\n\n%s', ...
           inputname(1),lasterr);
end










