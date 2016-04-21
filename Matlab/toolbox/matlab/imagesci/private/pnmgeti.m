function [int, count, msg] = pnmgeti(fid, n)
%PNMGETI Get integers from an ascii encoded PBM/PGM/PPM file.
%
%   [INT, COUNT, MSG] = PNMGETI(FID, N) tries to read N integers from the
%   ascii encoded PBM/PGM/PPM file with file identifier FID and returns the
%   integers in the vector INT.  COUNT is the number of values successfully
%   read.  MSG is an error message string if an error occurred, and an empty
%   matrix if an error did not occur.
%
%   If N is omitted, PNMGETI reads from the current file position to the end
%   of the file.
%
%   The main difference between PNMGETI(FID) and FSCANF(FID, '%d') is that
%   PNMGETI ignores PBM/PGM/PPM comments (which begin at a `#' character and
%   go to the end of line).  PNMGETI also ignores garbage, which is anything
%   that is neither whitespace, digit nor comment.

% Author:      Peter J. Acklam
% E-mail:      pjacklam@online.no

% Copyright 2001-2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:42 $

   % Check number of input arguments and assign default value to omitted
   % argument.
   if nargin < 2
      n = Inf;
   end

   % Initialize output arguments.
   int   = [];          % image data vector
   count = 0;           % number of elements read. same as length(int)
   msg   = '';          % error message string

   while 1

      % Calculate number of integers missing and try to read that many.
      ints_missing = n - count;
      [x, this_count] = fscanf(fid, '%d', ints_missing);

      % Append new data to main data vector and increment counter.
      int = [int ; x];
      count = count + this_count;

      % Return if we have got the desired number of elements.
      if count == n
         return
      end

      % Return if we have reached EOF.
      if feof(fid)
         msg = 'End of file reached too early.';
         return
      end

      % If we get here we have reached a comment or some garbage.  Garbage
      % is anything that is neither whitespace, digit nor comment.
      %
      char = fscanf(fid, '%c', 1);      % get next character
      if (char == '#')

         % Found a comment, so read the rest of the line and throw it away.
         fgetl(fid);

      else

         % We found some garbage, so give a message.
         msg = 'Garbage found where image data was expected.';

         % Read past the garbage and following whitespace (i.e., until first
         % number character or comment mark).
         %
         fscanf(fid, '%[^0-9#]');

         % Return if we have reached EOF.  This error message may overwrite
         % any error message telling about garbage, but that doesn't matter
         % since reaching EOF too early is a more serious error.
         %
         if feof(fid)
            msg = 'End of file reached too early.';
            return
         end

      end

   end
