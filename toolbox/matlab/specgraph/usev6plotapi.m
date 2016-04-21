function [res,args]=usev6plotapi(varargin)
% This undocumented function may be removed in a future release

%USEV6PLOTAPI determine plotting version
%  [V6,ARGS] = USEV6PLOTAPI(ARG1,ARG2,...) checks to see if the V6-compatible
%  plotting API should be used and return true or false in V6 and any
%  remaining arguments in ARGS.

%  if ARG1 is 'v6' the strip it off and return true
%  if ARG1 is 'group' the strip it off and return false
%  else return true  
%  if ARG1 is 'defaultv6', then strip it off and return true 
%  unless ARG2 is 'group', then strip it off too and return false.

%   Copyright 1984-2003 The MathWorks, Inc. 

% defaults
if nargout > 0
  res = ~isempty(getappdata(0,'UseV6PlotAPI'));
  args = varargin;
end

if nargin>0 && isa(varargin{1},'char') 
    if strcmp(varargin{1},'group')
        res = false;
        args = {varargin{2:end}};
    elseif strcmp(varargin{1},'v6')
        res = true;
        args = {varargin{2:end}};
    elseif strcmp(varargin{1},'defaultv6')
        if nargin>1 && isa(varargin{2},'char') 
             if strcmp(varargin{2},'group')
                 res = false;
                 args = {varargin{3:end}};
             elseif strcmp(varargin{2},'v6')
                 res = true;
                 args = {varargin{3:end}};
             else
                 res = true;
                 args = {varargin{2:end}};
             end
        else
            res = true;
            args = {varargin{2:end}};
        end
    elseif (nargin == 1) && strcmp(varargin{1},'on')
      if isempty(getappdata(0,'UseV6PlotAPI'))
	warning('MATLAB:usev6plotapi',...
		['You have enabled V6 compatability mode for graphics. ' ...
		 'This option will be removed in a future version of MATLAB.'])
	setappdata(0,'UseV6PlotAPI','on');
      end
    elseif (nargin == 1) && strcmp(varargin{1},'off')
      if isappdata(0,'UseV6PlotAPI')
	rmappdata(0,'UseV6PlotAPI');
      end
    end
end