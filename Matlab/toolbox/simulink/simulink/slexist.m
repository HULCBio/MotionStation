function  varargout = slexist(varargin)
% Check the existence of an input Simulink system (model or block).
% 
%  It provides the following output messages:
%    2 - if the system is existing and it's a model
%    1 - if the system is existing and it's a block
%    0 - if the system is not existing
%   -1 - if there is a hard error.
%  
%   See also SLLASTERROR, SLLASTWARNING, SLLASTDIAGNOSTIC.
%
  
%  Jun Wu, 11/27/2001
  
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $ $Date: 2004/04/15 00:49:27 $

% Input can be only one argument and output can not have more than one.
inerrmsg  = nargchk(1, 1, nargin);
outerrmsg = nargchk(0, 1, nargout);
  
if ~isempty([inerrmsg outerrmsg])
  error(sprintf([inerrmsg, '\n', outerrmsg]));
end

cache.lasterr  = lasterr;
cache.lastwarn = lastwarn;

cache.sllasterror = sllasterror;
cache.sllastwarn  = sllastwarning;
cache.sllastdiagn = sllastdiagnostic;

sys = varargin{1};
val = -1;

if ischar(sys) || ishandle(sys)
  try 
    hdl = get_param(sys, 'Handle');
    
    if findstr(get_param(hdl, 'Type'), 'diagram')
      val = 2;
    else
      val = 1;
    end
  catch
    lasterr(cache.lasterr);
    lastwarn(cache.lastwarn);

    sllasterror(cache.sllasterror);
    sllastwarning(cache.sllastwarn);
    sllastdiagnostic(cache.sllastdiagn);
    
    val = 0;
  end
else
  val = 0;
end

varargout{1} = val;

% end slexist.m

