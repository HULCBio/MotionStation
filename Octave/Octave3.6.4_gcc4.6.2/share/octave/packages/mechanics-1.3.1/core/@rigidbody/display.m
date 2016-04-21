## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

function display(obj)

  fields = fieldnames (obj);

  printf("\nRigid Body Object\n\n");
  for i = 1 : numel(fields)
    name = fields{i};
    content = obj.(name);
    
    if isstruct (content)
    
      printf("\n");
      printf ("    %s is a scalar strcuture with the fields:\n",name);
      subf = fieldnames (content);
    
      for j = 1 : numel(subf)

        name = subf{j};
        scont = content.(name);
        dim = size (scont);
        typep = class (scont);
        printFormatted(scont,typep,dim,name);

      end

    else

      dim = size (content);
      typep = class (content);
      printFormatted(content,typep,dim,name);

    end

  endfor

  printf("\n");

endfunction

function printFormatted(cont,typep,dim,name)

      if !isempty(cont)
        switch typep
          case 'double'
          
            if isscalar(cont)
              printf ("    %s = %g\n", name, cont);
            elseif max (size (cont)) < 10
              printf ("    %s =\n", name);
              str = disp(cont);
              str = strsplit (str, "\n",true);
              cellfun(@(x) printf ("      %s\n", x), str);
              printf("\n");
            else
              printf ("    %s = %dx%d %s\n", name, dim, [typep 'array']);
            end
            
          otherwise
          
            printf ("    %s = %dx%d %s\n", name, dim, typep);
            
          end
      else
        printf ("    %s = [](0x0)\n", name);
      end

endfunction
