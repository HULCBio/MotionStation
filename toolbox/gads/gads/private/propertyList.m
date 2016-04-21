function p = propertyList
%These are the properties that display, and generate operate on.
%   p = propertyList; returns a cell array of strings that list all of the
%   user visibnle properties in the gaoptimset struct. There are empty
%   strings in the list to seperate functional areas from one another.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/03/09 16:15:57 $

p = {
    'CreationFcn'
    'PopulationType'
    'PopInitRange'
    ''
    'OutputFcns'
    'PlotFcns'
    'Display'
    ''
    'FitnessScalingFcn'
    'SelectionFcn'
    'CrossoverFcn'
    'PopulationSize'
    'EliteCount'
    'CrossoverFraction'
    ''
    'MutationFcn'
    ''
    'MigrationInterval'
    'MigrationFraction'
    'MigrationDirection'
    ''
    'Generations'
    'TimeLimit'
    'FitnessLimit'
    'StallGenLimit'
    'StallTimeLimit'
    ''
    'HybridFcn'
};
