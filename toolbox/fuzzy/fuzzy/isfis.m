function tf = isfis(fis)
%ISFIS  Returns 1 (true) for FIS structures, 0 otherwise.

%   Author:  P. Gahinet
%   Revised: N. Hickey
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:20:11 $

if isa(fis,'struct') & all(ismember(...
        {'name'
        'type'
        'andMethod'
        'orMethod'
        'defuzzMethod'
        'impMethod'
        'aggMethod'
        'rule'},fieldnames(fis)))
    tf = 1;
else
    tf = 0;
end