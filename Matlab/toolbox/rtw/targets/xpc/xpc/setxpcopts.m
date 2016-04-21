function setxpcopts(mdl, saveMdl, compileMdl)
%SETXPCOPTS Set up a model for compiling with xPC Target
%
%   SETXPCOPTS(MDL, SAVEMDL, COMPILEMDL) sets up the xPC Target specific
%   options for the Simulink MDL. This is the same thing that can be set
%   from the RTW Options page. The arguments SAVEMDL and COMPILEMDL, when
%   set to 1, respectively save the model after setting the options and
%   compile the model with these options, and do nothing if set to 0. If
%   not specified, it is as if these options are set to 0. If MDL is not
%   specifed, the current model (as returned by GCS) is used.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2002/03/25 04:22:36 $

models = find_system('type', 'block_diagram');

if (nargin == 0)
  if isempty(gcs)
    error('No model loaded or specified');
  else
    mdl = gcs;
  end
end

if nargin < 2
  saveMdl = 0;
end

if nargin < 3
  compileMdl = 0;
end

if isempty(strmatch('xpcemptymdl', models))
  xpcemptymdl_loaded = 0;
else
  xpcemptymdl_loaded = 1;
end

if isempty(strmatch(mdl, models))
  open_system(mdl);
end

if ~xpcemptymdl_loaded
  load_system('xpcemptymdl');
end

set_param(mdl, 'Solver',              'ode4',            ...
               'FixedStep',           '0.001',           ...
               'RTWSystemTargetFile', 'xpctarget.tlc',   ...
               'RTWTemplateMakeFile', 'xpc_default_tmf', ...
               'RTWMakeCommand',      'make_rtw',        ...
               'ExtModeMexFile',      'ext_xpc',         ...
               'ExtModeBatchMode',     'off');
set_param(mdl, 'RTWOptions', get_param('xpcemptymdl', 'RTWOptions'));

if compileMdl
  rtwbuild(mdl);
end

if saveMdl
  save_system(mdl);
end

if ~xpcemptymdl_loaded
  bdclose('xpcemptymdl');
end
