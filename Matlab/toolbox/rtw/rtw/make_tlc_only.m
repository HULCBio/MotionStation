function make_tlc_only(varargin)
% MAKE_TLC_ONLY Invokes TLC with specified system target file

%       MAKE_TLC_ONLY invokes the Target Language Compiler to generate
%       code or reports.  Unlike MAKE_RTW, no specific files are
%       required to be generated and no build procedure is employed.

%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.8 $
 
if nargin > 0 & length(varargin{1}) > 4 & varargin{1}(1:4)=='mdl:'
  modelName = varargin{1}(5:end);
  firstBuildArg = 2;
else
  modelName = bdroot;
  firstBuildArg = 1;
end
if isempty(modelName) 
  error('Unable to obtain current model');
end
hModel = get_param(modelName,'handle');
  
systemTargetFile = deblank(get_param(hModel,'RTWSystemTargetFile'));
systemTargetFile = fliplr(deblank(fliplr(systemTargetFile)));

if isempty(systemTargetFile)
  error('No system target file specified');
end

tlc_cmd=['tlc -r ',modelName,'.rtw ',systemTargetFile];
eval(tlc_cmd);
