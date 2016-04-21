## Copyright (C) 2008, 2010 Luca Favatella <slackydeb@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{Population} =} __ga_initial_population__ (@var{GenomeLength}, @var{FitnessFcn}, @var{options})
## Create an initial population.
##
## @seealso{__ga_problem__}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.3

                                #TODO consider PopulationSize as a
                                #vector for multiple subpopolations

function Population = \
      __ga_initial_population__ (GenomeLength, FitnessFcn, options)
  if (isempty (options.InitialPopulation))
    Population(1:options.PopulationSize, 1:GenomeLength) = \
        options.CreationFcn (GenomeLength, FitnessFcn, options);
  else
    if (columns (options.InitialPopulation) != GenomeLength) ## columns (InitialPopulation) > 0
      error ("nonempty 'InitialPopulation' must have 'GenomeLength' columns");
    else ## rows (InitialPopulation) > 0
      nrIP = rows (options.InitialPopulation);
      if (nrIP > options.PopulationSize)
        error ("nonempty 'InitialPopulation' must have no more than \
            'PopulationSize' rows");
      elseif (nrIP == options.PopulationSize)
        Population(1:options.PopulationSize, 1:GenomeLength) = \
            options.InitialPopulation;
      else # rows (InitialPopulation) < PopulationSize

        ## create a complete new population, and then select only needed
        ## individuals (creating only a partial population is difficult)
        CreatedPopulation(1:options.PopulationSize, 1:GenomeLength) = \
            options.CreationFcn (GenomeLength, FitnessFcn, options);
        Population(1:options.PopulationSize, 1:GenomeLength) = vertcat \
            (options.InitialPopulation(1:nrIP, 1:GenomeLength),
             CreatedPopulation(1:(options.PopulationSize - nrIP),
                               1:GenomeLength));
      endif
    endif
  endif
endfunction


%!test
%! GenomeLength = 2;
%! options = gaoptimset ();
%! Population = __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);
%! assert (size (Population), [options.PopulationSize, GenomeLength]);

%!test
%! GenomeLength = 2;
%! options = gaoptimset ("InitialPopulation", [1, 2; 3, 4; 5, 6]);
%! Population = __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);
%! assert (size (Population), [options.PopulationSize, GenomeLength]);


## nonempty 'InitialPopulation' must have 'GenomeLength' columns

%!error
%! GenomeLength = 2;
%! options = gaoptimset ("InitialPopulation", [1; 3; 5]);
%! __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);

%!error
%! GenomeLength = 2;
%! options = gaoptimset ("InitialPopulation", [1, 1, 1; 3, 3, 3; 5, 5, 5]);
%! __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);


## nonempty 'InitialPopulation' must have no more than 'PopulationSize' rows

%!error
%! GenomeLength = 2;
%! options = gaoptimset ("InitialPopulation", [1, 2; 3, 4; 5, 6], "PopulationSize", 2);
%! __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);
