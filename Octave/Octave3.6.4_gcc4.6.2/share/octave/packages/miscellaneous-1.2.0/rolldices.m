## Copyright (C) 2009 Jaroslav Hajek <highegg@gmail.com>
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
## @deftypefn{Function File} rolldices (@var{n})
## @deftypefnx{Function File} rolldices (@var{n}, @var{nrep}, @var{delay})
## Returns @var{n} random numbers from the 1:6 range, displaying a visual selection
## effect.
##
## @var{nrep} sets the number of rolls, @var{delay} specifies time between
## successive rolls in seconds. Default is nrep = 25 and delay = 0.1.
##
## Requires a terminal with ANSI escape sequences enabled.
## @end deftypefn

function numbers = rolldices (n, nrep = 25, delay = .1)
  if (nargin != 1)
    print_usage ();
  endif

  persistent matrices = getmatrices ();

  screen_cols = getenv ("COLUMNS");
  if (isempty (screen_cols))
    screen_cols = 80;
  else
    screen_cols = str2num (screen_cols);
  endif

  dices_per_row = floor ((screen_cols-1) / 7);

  oldpso = page_screen_output (0);

  numbers = [];

  unwind_protect
    while (n > 0)
      m = min (n, dices_per_row);
      for i = 1:nrep
        if (i > 1)
          puts (char ([27, 91, 51, 70])); 
          sleep (delay);
        endif
        nums = ceil (6 * rand (1, m));
        disp (matrices(:,:,nums)(:,:));
      endfor
      numbers = [numbers, nums];
      n -= m;
      puts ("\n");
    endwhile
  unwind_protect_cleanup
    page_screen_output (oldpso);
  end_unwind_protect

endfunction

function matrices = getmatrices ()
  lbrk = [27, 91, 55, 109](ones (1, 3), :);
  rbrk = [27, 91, 50, 55, 109](ones (1, 3), :);
  spcs = [32, 32; 32, 32; 32, 32];
  dchrs = reshape(
  ["     @    @    @   @@   @@   @";
   "  @         @         @  @   @";
   "         @    @@   @@   @@   @"], [3, 5, 6]);

  matrices = mat2cell (dchrs, 3, 5, ones (1, 6));
  matrices = cellfun (@(mat) [spcs, lbrk, mat, rbrk], matrices, "UniformOutput", false);
  matrices = cat (3, matrices{:});
endfunction
