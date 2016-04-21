## Copyright (C) 2005-2012 Etienne Grossmann <etienne@egdn.net>
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

##  s = vrml_TimeSensor (...)   - Low-level vrml TimeSensor node
##  
##  s is a vrml node with possible fields :
##  ------------------------------------------------------------------
## TimeSensor { 
##   exposedField SFTime   cycleInterval 1       # (0,inf)
##   exposedField SFBool   enabled       TRUE
##   exposedField SFBool   loop          FALSE
##   exposedField SFTime   startTime     0       # (-inf,inf)
##   exposedField SFTime   stopTime      0       # (-inf,inf)
##   eventOut     SFTime   cycleTime
##   eventOut     SFFloat  fraction_changed      # [0, 1]
##   eventOut     SFBool   isActive
##   eventOut     SFTime   time
## }
##  ------------------------------------------------------------------
##
## Options :
## Beyond all the fields of the node, it is also possible to use the option
##
## "DEF", name : The created node will be preceded by 'DEF name ', so that
##               it is further possible to refer to it.
##
## See also : 

function s = vrml_TimeSensor (varargin)

verbose = 0;

tpl = struct ("cycleInterval", "SFTime",\
"startTime",     "SFTime",\
"stopTime",      "SFTime",\
"enabled",       "SFBool",\
"loop",          "SFBool"
);

headpar = {};
dnode = struct ();

				# Transform varargin into key-value pairs
i = j = k = 1;			# i:pos in new varargin, j:pos in headpar,
				# k:pos is old varargin.
while i <= length (varargin) && \
      ! (ischar (varargin{i}) && isfield (tpl, varargin{i}))
  
  if j <= length (headpar)

    if verbose
      printf ("vrml_TimeSensor : Assume arg %i is '%s'\n",k,headpar{j});
    end

    ##varargin = splice (varargin, i, 0, headpar(j));
    varargin = {varargin{1:i-1}, headpar(j), varargin{i:end}};
    j ++; 
    i += 2;
    k++;
  else
    error ("vrml_TimeSensor : Argument %i should be string, not '%s'",\
	   k,typeinfo (varargin{i}));
  end
end

DEF = 0;

if rem (length (varargin), 2), error ("vrml_TimeSensor : Odd n. of arguments"); end

l = {"TimeSensor {\n"};
i = 1;
while i < length (varargin)

  k = varargin{i++};	# Read key

  if ! ischar (k)
    error ("vrml_TimeSensor : Arg n. %i should be a string, not a %s.",\
	   i-1, typeinfo (k));
  end
  if ! isfield (tpl, k) && ! strcmp (k,"DEF")
    error ("vrml_TimeSensor : Unknown field '%s'. Should be one of :\n%s",\
	    k, sprintf ("   '%s'\n",fieldnames (tpl)'{:}));
  end

  v = varargin{i++};	# Read value
				# Add DEF
  if strcmp (k,"DEF")

    if verbose, printf ("vrml_TimeSensor : Defining node '%s'\n",v); end

    if DEF, error ("vrml_TimeSensor : Multiple DEFs found"); end
    l = {sprintf("DEF %s ", v), l{:}};
    DEF = 1;

  else				# Add data field

    if verbose
      printf ("vrml_TimeSensor : Adding '%s' of type %s, with arg of type %s\n",\
	      k,getfield(tpl,k),typeinfo (v));
    end
    tmp = getfield(tpl,k);
    if strcmp (tmp(2:end), "FNode")

      if verbose, printf ("vrml_TimeSensor : Trying to learn type of node\n"); end

      if iscell (v)		# v is list of arguments

				# Check whether 1st arg is node type's name.
        n = v{1};

	if all (exist (["vrml_",tn]) != [2,3,5])
	  			# If it isn't type's name, use default type.
	  if isfield (dnode, k)
	    if verbose
	      printf ("vrml_TimeSensor : Using default type : %s\n",getfield(dnode,k));
	    end
	    v = {getfield(dnode,k), v{:}};
	  else
	    error ("vrml_TimeSensor : Can't determine type of node '%s'",k);
	  end
	else
	  if verbose
            printf ("vrml_TimeSensor : 1st list element is type : %s\n",tn);
	  end
	end
				# If v is not a list, maybe it has a default
				# node type type (otherwise, it's be sent
				# plain.
      elseif isfield (dnode, k)
	if verbose
	  printf ("vrml_TimeSensor : Using default type : %s\n",dnode.(k));
	end
	v = {getfield(dnode,k), v{:}};
      end
    end
    l = {l{:}, k, " ", data2vrml(getfield(tpl,k),v),"\n"};
  end
  
end

l{end+1} = "}\n";

s = "";
for i=1:numel(l)
  s = [s, sprintf(l{i})];
endfor
### Stupid strcat removes trailing spaces in l's elements
### s = strcat (l{:});
endfunction

