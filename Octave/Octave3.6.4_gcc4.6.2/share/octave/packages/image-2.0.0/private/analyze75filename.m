%% Copyright (C) 2012 Adam H Aitkenhead <adamaitkenhead@hotmail.com>
%% Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

%% private function with common code for the analyze75info and read functions

function filename = analyze75filename (filename)

  %% Check filename
  if (exist (filename, 'dir'))
    filelist = dir ([filename, filesep, '*.hdr']);
    if (numel (filelist) == 1)
      filename = [filename, filesep, filelist.name];
    elseif (numel (filelist) > 1)
      error ('analyze75: `filename'' is a directory with multiple hdr files.')
    else
      error ('analyze75: `filename'' is a directory with no hdr files.')
    end
  elseif (~exist (filename, 'file'))
      error ('analyze75: no file `%s''', filename)
  end

  %% Strip the filename of the extension
  fileextH = strfind (filename, '.hdr');
  fileextI = strfind (filename, '.img');
  if (~isempty (fileextH))
    filename = filename(1:fileextH(end)-1);
  elseif (~isempty (fileextI))
    filename = filename(1:fileextI(end)-1);
  else
    filename = filename;
  end
end
