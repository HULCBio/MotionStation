## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{paths} = } getpath (@var{ids})
## Returns paths in @var{ids}.
##
## @end deftypefn

function paths = getpath(obj, varargin)

  if !isempty(varargin)
  
    ids = varargin;
    if iscell (ids) && numel(ids) == 1 && iscell(ids{1}) # dealing with ids given as cell
      ids = ids{1};

      if !all ( cellfun (@ischar, ids) )
       print_usage
      end

    elseif !all ( cellfun (@ischar, ids) )
     print_usage
    end
    
  else
    paths = obj.Path;
    return
  end

  tf = ismember (ids, fieldnames (obj.Path));

  cellfun (@(s) printf("'#s' is not a valid path id.\n", s) , {ids{!tf}});

  paths = [];
  if any (tf)
    stuff = {ids{tf}};
    
    for i = 1: numel(stuff)
      paths{i} = obj.Path.(ids{i}).data;
    endfor
    
    
    # Variation
#    paths = cellfun(@(s) obj.Path.(s).data, stuff,'UniformOutput',false);
    
    # Another variation
#    paths = cellfun(@(s) getfield(obj,'Path').(s).data, stuff,'UniformOutput',false);
    
    # Yet another
#    paths = cellfun(@(s) getfield(obj.Path,s).data, stuff,'UniformOutput',false);    

    # Yet yet another
#    dummy = @(s) obj.Path.(s).data;
#    paths = cellfun(dummy, stuff,'UniformOutput',false);    
    
    if numel(paths) == 1
      paths = paths{1};
    end
  end

endfunction

