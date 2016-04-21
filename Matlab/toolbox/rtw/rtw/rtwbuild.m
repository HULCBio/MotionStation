function rtwbuild(mdl)
%RTWBUILD - Invoke the RTW build procedure on a block diagram
%
%   rtwbuild('model') will invoke the Real-Time Workshop build procedure
%   using the Real-Time Workshop configuration settings in the model to
%   create an executable from your model.
%

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $

  if nargin < 1
      error('usage: rtwbuild(''model'')');
  end
  slbuild(mdl, 'StandaloneRTWTarget', 'OkayToPushNags', false);

%endfunction rtwbuild

%[eof] rtwbuild.m
