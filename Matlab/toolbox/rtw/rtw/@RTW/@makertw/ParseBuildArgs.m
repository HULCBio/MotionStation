function ParseBuildArgs(h, args)
% PARSEBUILDARGS:
%	Parse the build arguments passed into make_rtw
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/15 00:23:57 $

if length(args) > 0 && ~ischar(args{1})
  h.MdlRefBuildArgs = args{1};
  startArgs = 2;
  h.DispHook = h.MdlRefBuildArgs.mDispHook;
else
  %% Have a default function
  h.MdlRefBuildArgs.UpdateTopModelReferenceTarget = false;
  h.MdlRefBuildArgs.ModelReferenceTargetType = 'NONE';
  h.MdlRefBuildArgs.OkayToPushNags = false;
  h.MdlRefBuildArgs.StoredChecksum = [];
  h.MdlRefBuildArgs.UseChecksum = false;
  h.MdlRefBuildArgs.Verbose     = false;
  startArgs = 1;
  h.DispHook = {@disp};
end


h.BuildArgs = '';
for i = startArgs:length(args)
    h.BuildArgs = [h.BuildArgs, args{i}, ' '];
end
if length(h.BuildArgs) > 0
    h.BuildArgs(end) = [];
end

h.InitRTWOptsAndGenSettingsOnly = 0;

% Get the model name and handle. Pluck:
%  mdl:modelName  => Build
% or
%  ini:modelName  => Initialize RTWOptions and RTWGenSettings, then exit.
%
if length(h.BuildArgs) > 4 && ...
        (all(h.BuildArgs(1:4)=='mdl:') || all(h.BuildArgs(1:4)=='ini:'))
    if all(h.BuildArgs(1:4)=='ini:')
        h.InitRTWOptsAndGenSettingsOnly = 1;
    end
    sp = findstr(h.BuildArgs,' ');
    if ~isempty(sp)
        h.ModelName = h.BuildArgs(5:sp(1)-1);
        h.BuildArgs(1:sp(1)) = [];
    else
        h.ModelName = h.BuildArgs(5:end);
        h.BuildArgs = '';
    end
else
    h.ModelName = bdroot;
end %if
if isempty(h.ModelName)
    error('Unable to obtain current model name.');
end %if

% get Model handle
h.ModelHandle = get_param(h.ModelName,'handle');

