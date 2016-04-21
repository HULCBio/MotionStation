## Copyright (C) 2006 Hansgeorg Schwibbe
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

## Creates a latex file from a csv file. The generated latex file contains a 
## tabular with all values of the csv file. The tabular can be decorated with 
## row and column titles. The generated latex file can be inserted in any latex
## document by using the '\input{latex file name without .tex}' statement.
##
## Usage: 
##  - csv2latex(csv_file, csv_sep, latex_file)
##  - csv2latex(csv_file, csv_sep, latex_file, tabular_alignments)
##  - csv2latex(csv_file, csv_sep, latex_file, tabular_alignments, has_hline)
##  - csv2latex(csv_file, csv_sep, latex_file,   
##              tabular_alignments, has_hline, column_titles)
##  - csv2latex(csv_file, csv_sep, latex_file, tabular_alignments,
##              has_hline, column_titles, row_titles)
##
## Parameters:
##  csv_file - the path to an existing csv file
##  csv_sep - the seperator of the csv values
##  latex_file - the path of the latex file to create     
##  tabular_alignments - the tabular alignment preamble (default = {'l','l',...})
##  has_hline - indicates horizontal line seperator (default = false)
##  column_titles - array with the column titles of the tabular (default = {})
##  row_titles - array with the row titles of the tabular (default = {})
##
## Examples:
##  # creates the latex file 'example.tex' from the csv file 'example.csv' 
##  csv2latex("example.csv", '\t', "example.tex");
##
##  # creates the latex file with horizontal and vertical lines
##  csv2latex('example.csv', '\t', 'example.tex', {'|l|', 'l|'}, true);
## 
##  # creates the latex file with row and column titles
##  csv2latex('example.csv', '\t', 'example.tex', {'|l|', 'l|'}, true, 
##            {'Column 1', 'Column 2', 'Column 3'}, {'Row 1', 'Row 2'});

function csv2latex (csv_file, csv_sep, latex_file, tabular_alignments, has_hline, column_titles, row_titles)

  ## set up the default values
  if nargin < 7
   row_titles = {};
  end
  if nargin < 6
   column_titles = {};
  end
  if nargin < 5
   has_hline = false;
  end
  if nargin < 4
   tabular_alignments = {};
  end

  ## load the csv file and create the csv cell
  [fid, msg] = fopen (csv_file, 'r'); # open the csv file to read
  csv = cell();
  if fid != -1
    [val, count] = fread(fid); # read all data from the file
    fclose(fid); # close the csv file after reading
    csv_value = '';
    line_index = 1;
    value_index = 1;
    for index = 1:count
      if val(index) == csv_sep
        csv(line_index, value_index) = csv_value;
        value_index++;
        csv_value = '';
      elseif (val(index) == '\n' || (val(index) == '\r' && val(index+1) == '\r'))
        csv(line_index, value_index) = csv_value;
        value_index++;
        csv_value = '';
        value_index = 1;
        line_index++;
      else
        csv_value = sprintf('%s%c', csv_value, val(index));
      end
    end
  end

  ## get the size and length values
  [row_size, col_size] = size(csv);
  alignment_size = length(tabular_alignments);
  column_title_size = length(column_titles);
  row_title_size = length(row_titles);

  ## create the alignment preamble and the column titles
  alignment_preamble = '';
  tabular_headline = '';
  if row_title_size != 0
    current_size = col_size + 1;
  else
    current_size = col_size;
  end
  for col_index = 1:current_size
   if col_index <=  alignment_size
     alignment_preamble = sprintf ('%s%s', alignment_preamble, tabular_alignments(col_index));
   else
     alignment_preamble = sprintf ('%sl', alignment_preamble);
   end
   if column_title_size != 0
     if col_index <= column_title_size
       if col_index == 1
         tabular_headline = sprintf ('%s', column_titles(col_index));
       else
         tabular_headline = sprintf ('%s & %s', tabular_headline, column_titles(col_index));
       end
     else
       tabular_headline = sprintf ('%s &', tabular_headline);       
     end
   end
  end

  ## print latex file
  [fid, msg] = fopen (latex_file, 'w'); # open the latex file for writing
  if fid != -1
    fprintf (fid, '\\begin{tabular}{%s}\n', alignment_preamble); # print the begin of the tabular
    if column_title_size != 0
      if has_hline == true
        fprintf (fid, '  \\hline\n');
      end
      fprintf (fid, '  %s \\\\\n',  tabular_headline); # print the headline of the tabular
    end
    for row_index = 1:row_size
      if has_hline == true
        fprintf (fid, '  \\hline\n');
      end
      for col_index = 1:col_size
        if col_index == 1
          if row_title_size != 0
            if row_index <= row_title_size
              fprintf (fid, '  %s & ', row_titles(row_index)); # print the row title
            else
              fprintf (fid, '  & '); # print an empty row title
            end
          end
          fprintf (fid, '  %s ', csv{row_index, col_index});
        else
         fprintf (fid, '& %s ', csv{row_index, col_index});
        end
      end
      fprintf (fid, '\\\\\n');
    end
    if has_hline == true
      fprintf (fid, '  \\hline\n');
    end
    fprintf (fid, '\\end{tabular}', alignment_preamble); # print the end of the tabular
    fclose(fid); # close the latex file after writing
  end
end
