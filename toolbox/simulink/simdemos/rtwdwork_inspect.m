% $Revision: 1.2 $
% $Date: 2002/04/10 18:39:30 $
%
% Copyright 1994-2002 The MathWorks, Inc.
%
% Abstract:
%   Inspect code script for sfcndemo_sfun_rtwdwork

function rtwdwork_inspect(f)

dirname = 'sfcndemo_sfun_rtwdwork_ert_rtw';

if ~exist(dirname)
  try, rtwbuild('sfcndemo_sfun_rtwdwork'); catch, end
end

edit(fullfile('.',dirname,f));



