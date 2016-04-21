function rtwdemo_inspect(bd, ext)
%RTWDEMO_INSPECT  Open files generated from demo models for inspection.
% 
%   This script works with models that are configured to use ert.tlc as the 
%   system target file (or grt.tlc if Embedded Coder license is not installed).

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/06/05 17:28:04 $

if ecoderinstalled
  stfName = 'ert';
else
  stfName = 'grt';
end

dirName = [bd, '_', stfName, '_rtw'];

fileToInspect = fullfile('.', dirName, [bd, ext]);

if ~exist(fileToInspect)
  rtwbuilddemomodel(bd);
end

edit(fileToInspect);



