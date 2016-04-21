function paramValue = dspGetEditBoxParamValue(blk,paramName)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/05/18 02:18:24 $

  %bName = get_param(blk,'name');
  %disp(['dspGEBPV: blk ' bName ', param ' paramName])
  
  wsv=get_param(blk,'maskwsvariables');
  jj = find(strcmp({wsv.Name},paramName));
  paramValue = wsv(jj).Value;
