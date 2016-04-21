## Copyright (C) 2012 Luca Favatella <slackydeb@gmail.com>
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
## @deftypefn{Script File} {} test_ga
## Execute all available tests at once.
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Created: March 2012
## Version: 0.3

## Creation
test gacreationuniform

## Fitness Scaling
test fitscalingrank

## Selection
test selectionstochunif

## Crossover
test crossoverscattered

## Mutation
test mutationgaussian

## Utility
test rastriginsfcn

## Genetic Algorithm
test gaoptimset
test ga

## Private functions
test __ga_initial_population__
test __ga_problem_update_state_at_each_generation__
