function out=newfis(fisName,fisType,andMethod,orMethod,impMethod,aggMethod,defuzzMethod)
%NEWFIS Create new FIS.
%   FIS=NEWFIS(FISNAME) creates a new Mamdani-style FIS structure
%
%   FIS=NEWFIS(FISNAME, FISTYPE) creates a FIS structure for a Mamdani or 
%   Sugeno-style system with the name FISNAME.
%
%   FIS=NEWFIS(FISNAME, FISTYPE, andMethod, orMethod, impMethod, ...
%              aggMethod, defuzzMethod)
%   specifies the methods for AND, OR, implication, aggregation, and 
%   defuzzification, respectively.
%
%   See Also
%       readfis, writefis
%
%   Kelly Liu 4-5-96 
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.18.2.2 $  $Date: 2004/04/10 23:15:32 $

if (nargin>=1), name=fisName; end
if (nargin<2), fisType='mamdani'; else, fisType = fisType; end
if strcmp(fisType,'mamdani'),
    if (nargin<3), andMethod='min'; end
    if (nargin<4), orMethod='max'; end
    if (nargin<7), defuzzMethod='centroid'; end
end


if (nargin<5), impMethod='min'; end
if (nargin<6), aggMethod='max'; end


if strcmp(fisType,'sugeno'),
    if (nargin<3), andMethod='prod'; end
    if (nargin<4), orMethod='probor'; end
    if (nargin<7), defuzzMethod='wtaver'; end
    if (nargin<5), impMethod='prod'; end
    if (nargin<6), aggMethod='sum'; end
end
out.name=name;
out.type=fisType;
out.andMethod=andMethod;
out.orMethod=orMethod;
out.defuzzMethod=defuzzMethod;
out.impMethod=impMethod;
out.aggMethod=aggMethod;

% Create default values for the FIS structure input output and rule
out.input=[];
out.output=[];
out.rule=[];