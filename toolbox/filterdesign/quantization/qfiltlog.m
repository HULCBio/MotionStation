function qfiltlog(S)
%QFILTLOG  Display quantized filter quantization information.
%
%   This function is being superseded by QREPORT.   Use QREPORT
%   instead. 
%
%   See also QREPORT.

%   QFILTLOG(S) displays the quantized filter log data, S, from the
%   output of the quantized filter command QFILT/FILTER.
%
%   S is a MATLAB structure with each data path's maximum and minimum value
%   encountered, as well as its total number of overflows and underflows.  This
%   information is stored on a section by section basis.  The five data path
%   fields are:
%       S.coefficient  -  [1 x N] structure array for N cascaded sections.
%       S.input        -  [1 x 1] structure array. 
%       S.output       -  [1 x 1] structure array. 
%       S.multiplicand -  [1 x N] structure array for N cascaded sections.
%       S.product      -  [1 x N] structure array for N cascaded sections.
%       S.sum          -  [1 x N] structure array for N cascaded sections.
%
%   If there is more than one section in the filter, then the statistics for
%   each section will be listed on a separate line, starting with section 1
%   at the top.
%
%   Example:
%      [b,a] = butter(2,.5);
%      Hq = qfilt('df2t',{b,a});
%      x=randn(40,1);
%      [y,zf,S]=filter(Hq,x);
%      qfiltlog(S)
%
%   See also QFILT/FILTER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/14 15:36:20 $

fprintf('%12s%15s%15s%15s%15s%15s\n','','Max','Min','NOverflows',...
    'NUnderflows','NOperations')
  report(S.coefficient,'Coefficient');
  report(S.input,'Input');
  report(S.output,'Output');
  report(S.multiplicand,'Multiplicand');
  report(S.product,'Product');
  report(S.sum,'Sum');

function report(s,name)
n=length(s);
for k=1:n
  if ischar(s(k).min)
    fmt = '%12s%15s%15s%15.10g%15.10g%15.10g\n';
  else
    fmt = '%12s%15.4g%15.4g%15.10g%15.10g%15.10g\n';
  end
  % Only print the name on the first section
  if k==1
    fprintf(fmt, name, s(k).max, s(k).min, s(k).nover, s(k).nunder, ...
        s(k).noperations)  
  else
    fprintf(fmt, ' ', s(k).max, s(k).min, s(k).nover, s(k).nunder, ...
        s(k).noperations)
  end    
end
