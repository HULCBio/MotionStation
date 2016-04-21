function varargout = getfileinfo(varargin)
%GETFILEINFO Parse the input for OBJ2MFILE.
%
%    GETFILEINFO parses the input into the ERRORCODE, SYNTAX,
%    DEFINELIST, FILENAME, FILE and PATH arguments for the 
%    function OBJ2MFILE.
%

%    GETFILEINFO is a helper function for OBJ2MFILE.
%

%    MP 6-08-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:42:06 $

% Initialize variables
errflag = 0;
syntax = '';
definelist = '';
filename = '';
file = '';
path = '';

% Set up the filename and syntax variables from the provided input.
switch nargin
case 0
   lasterr('The FILENAME input argument must be specified.');
   errflag = 1;
   varargout = {errflag,syntax,definelist,filename,file,path};
   return;
case 1
   syntax = 'set';
   definelist = 'default';
case 2
   if strcmp(lower(varargin{2}), 'all')
      syntax = 'set';
      definelist = 'all';
   else
      syntax = lower(varargin{2});
      definelist = 'default';
   end
case 3
   syntax = lower(varargin{2});
   definelist = lower(varargin{3});
end

% Setup the filename variables from the provided input
[filename file path] = localBreakName(varargin{1});
   
% Determine if correct parameters were passed.
if isempty(strmatch(syntax, {'set','dot','named'}))
   lasterr(['Invalid SYNTAX specified.  Valid SYNTAX are ''dot'',',...
         '''set'' and ''named''.']);
   errflag = 1;
   varargout = {errflag,syntax,definelist,filename,file,path};
   return;
end

if isempty(strmatch(definelist, {'default', 'all'}))
   lasterr(['Unknown option ''' definelist '''.']);
   errflag = 1;
   varargout = {errflag,syntax,definelist,filename,file,path};
   return;
end

varargout = {errflag,syntax,definelist,filename,file,path};

%******************************************************
% Determine the filename with and without the extension
% and path to be used when saving the M-file and when 
% writing the function line
function [filename, file, path] = localBreakName(filename)

[path, file, ext] = fileparts(filename);

% If an extension was not given add '.m' to the filename.
if isempty(ext)
   filename = [file '.m'];
else
   filename = [file ext];
end

% If a path was given add it to the filename.
if ~(isempty(path))
   filename = [path filesep filename];
end
