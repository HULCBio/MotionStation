function indicies = populationIndicies(population)
%POPULATIONINDICIES Find the indicies of each sub-population
%   indicies = populationIndicies(population); returns a 2 by n array
%   containing the locations of each subpopulation in the population aray.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2004/01/16 16:50:03 $

lengths = cumsum(population);
lengths = lengths(1:(end-1));
starts = [1, 1 + lengths];
ends = starts + population - 1;

indicies = [starts;ends];