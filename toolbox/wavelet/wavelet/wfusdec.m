function [Dfus,Tfus] = wfusdec(D1,D2,AfusMeth,DfusMeth)
%WFUSDEC Fusion of two wavelet decompositions.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Jan-2003.
%   Last Revision: 15-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:40:10 $

% Check arguments.
if nargin==3 , DfusMeth = AfusMeth; end

okTREE = false;
if isa(D1,'wdectree') & isa(D2,'wdectree')
    okTREE = true;
    Tfus = D1;
    tn = leaves(D1);
    D1 = read(D1,'data',tn);
    tn = leaves(D2);
    D2 = read(D2,'data',tn);
end
if iscell(D1) & iscell(D2)
    nbCell = length(D1);
    Dfus   = cell(size(D1));
    Dfus{1} = wfusmat(D1{1},D2{1},AfusMeth);
    for k=2:nbCell
        Dfus{k} = wfusmat(D1{k},D2{k},DfusMeth);
    end
    if okTREE
        Tfus = write(Tfus,'data',Dfus);
        Dfus = rnodcoef(Tfus);
    end
else
    error('Invalid Inputs');
end
