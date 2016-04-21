function report = qreportinit(n,coefficientreport)
%QREPORTINIT  Initialize quantization report field of object.
%   S = QREPORTINIT(N) initializes the quantization report for a filter
%   with N sections.  See QREPORT for a description of the fields.
%
%   S = QREPORTINIT(N,COEFFICIENTREPORT) with the additional input
%   argument initializes the coefficient field with structure
%   COEFFICIENTREPORT.  This is so that the coefficient information is not
%   lost from when the filter is initially quantized.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/14 15:27:49 $

report1 = myqreportinit(1);
reportn = myqreportinit(n);

if nargin<2
  coefficientreport = reportn;
end

report = struct(...
    'coefficient',coefficientreport,...
    'input',report1,...
    'output',report1,...
    'multiplicand',reportn,...
    'product',reportn,...
    'sum',reportn);

function reportk = myqreportinit(n)
%MYQREPORTINIT  Initialize one subfield.
%    MYQREPORTINIT(N) initializes one subfield with N elements.
[mx{1:n}] = deal('reset');     % max
[mn{1:n}] = deal('reset');     % min
[no{1:n}] = deal(0);           % nover
[nu{1:n}] = deal(0);           % nunder
[nq{1:n}] = deal(0);           % noperations
reportk = struct('max',mx,'min',mn,'nover',no,'nunder',nu,'noperations',nq);

