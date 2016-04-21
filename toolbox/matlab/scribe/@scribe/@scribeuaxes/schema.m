function schema
%SCHEMA defines the SCRIBE.SCRIBEUAXES schema
%
%  See also PLOTEDIT

%   Copyright 1984-2003 The MathWorks, Inc.

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg,'scribeuaxes',hgPk.findclass('axes'));

