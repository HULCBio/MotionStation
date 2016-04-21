## Copyright (C) 2008, 2009, 2010 Luca Favatella <slackydeb@gmail.com>
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

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.2.3

function default_options = __gaoptimset_default_options__ ()
  default_options.CreationFcn = @gacreationuniform;
  default_options.CrossoverFcn = @crossoverscattered;
  default_options.CrossoverFraction = 0.8;
                                #default_options.Display = "final";
                                #default_options.DistanceMeasureFcn gamultiobj
  default_options.EliteCount = 2;
  default_options.FitnessLimit = -Inf;
  default_options.FitnessScalingFcn = @fitscalingrank;
  default_options.Generations = 100;
                                #default_options.HybridFcn = [];
                                #default_options.InitialPenalty = 10;
  default_options.InitialPopulation = [];
  default_options.InitialScores = [];
                                #default_options.MigrationDirection = "forward";
                                #default_options.MigrationFraction = 0.2;
                                #default_options.MigrationInterval = 20;
  default_options.MutationFcn = {@mutationgaussian, 1, 1};
                                #default_options.OutputFcns = [];
                                #default_options.ParetoFraction = 0.35;
                                #default_options.PenaltyFactor = 100;
                                #default_options.PlotFcns = [];
                                #default_options.PlotInterval = 1;
  default_options.PopInitRange = [0; 1];
  default_options.PopulationSize = 20;
                                #default_options.PopulationType = "doubleVector";
  default_options.SelectionFcn = @selectionstochunif;
                                #default_options.StallGenLimit = 50;
                                #default_options.StallTimeLimit = Inf;
  default_options.TimeLimit = Inf;
                                #default_options.TolCon = 1e-6;
                                #default_options.TolFun = 1e-6;
  default_options.UseParallel = "never";
  default_options.Vectorized = "off";
endfunction