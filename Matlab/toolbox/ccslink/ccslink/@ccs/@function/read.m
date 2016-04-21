function resp = read(ff,varargin)
% READ Reads the function's return value.
%  0 = READ(FF) Reads the return value of the function object FF.
%
%  0 = READ(FF,VARARGIN) Depending on the return value's class, READ
%  accepts variable parameters.
%
%  Note: read(ff) is the same as read(ff.outputvar) 
% 
%  See also WRITE.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2003/11/30 23:09:07 $

nargchk(1,3,nargin);    
if ~ishandle(ff)
    error('First Parameter must be a FUNCTION handle');
end

% Do not read if type 'void'
if IsVoidType(ff)
    warning('Unable to read ''void'' output.');
    return;
end

% Read object
obj = ff.outputvar;
if nargin==1        resp = read(obj                                    );
elseif nargin==2    resp = read(obj,varargin{1}                        );
elseif nargin==3    resp = read(obj,varargin{1},varargin{2}            );
elseif nargin==4    resp = read(obj,varargin{1},varargin{2},varargin{3});
else                str  = call_arbitrary_args(nargin);  resp = eval(str);
end

%-------------------------------------------
function resp = IsVoidType(ff)
if strcmpi(ff.type,'void'), %& isempty(ff.outputvar),
    resp = 1;
else    
    resp = 0;
end

%-------------------------------------------
function str = call_arbitrary_args(num_args)
str = 'read(obj,varargin{1},varargin{2},varargin{3},';
for i=4:num_args-1
    str = horzcat(str,['varargin{' num2str(i) '},']);
end
str(end) = ')';
str = horzcat(str,';');

% [EOF] read.m