function addtipfcn(this,tipfcn)
%ADDTIPFCN  Adds a buttondownfcn to each curve in each view contained in
%           a dataview object 
 
%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:24 $

for ct = 1:length(this.View)
    
    info = struct('Response',this,...
        'Source',this.DataSrc,...
        'LineTip',handle(NaN),...
        'Row',0,...
        'Col',0,...
        'ViewNumber',ct);
    
    this.View(ct).addtipfcn(info,tipfcn);
end