function flg=mpcinfo(mat)
%MPCINFO Return information about a matrix.
%	flag=mpcinfo(mat).
% Type of matrix is determined.  Types include constant matrix,
% system matrix, varying matrix, matrix in MPC Mod format or
% matrix in MPC Step format.
%
% Input:
%  mat:	the matrix to be checked.
%
% Output:
% flag < 0   Normal (constant) matrix.
%      = 1   System matrix used in mu-tools
%      = 2   Varying matrix.
%      = 4   MPC "mod" format.
%      = 5   MPC "step" format.

% Please see manual for more details about output for each type.
%
% See also MOD2FRSP.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage:  flag = mpcinfo(mat)');
   return
end
[nr,nc] = size(mat);
if nr == 1 | isempty(mat)
   flg = -1;
elseif isnan(mat(2,1))
   if nc < 7,
      disp('Error:  matrix in MPC Mod format must have at least 7 columns.');
      return
   end
   flg = 4;
else
   ny = mat(nr-1,1);
   flg = 0;
   if ny < nr-2 & ny > 0
      nout = mat(nr-floor(ny)-1:nr-2,1);
      ncoe = (nr - 2)/ny - 1;
      if floor(ny) == ny & ny > 0,
         ncount = 0;
         for i = 1:ny,
            if nout(i) == 0 | nout(i) == 1
               ncount = ncount + 1;
            end
         end
         if ncount == ny,
            flg = 5;
         end
      end
      if nc >= 2,
         cmat = mat(nr-floor(ny)-1:nr,2:nc);
         if all(all(cmat == 0))
            flg = 5;
         end
      end
   end
   if mat(nr,1) > 0 & flg == 5 & floor(ncoe) == ncoe  %& ncoe >= 1,
      flg = 5;
   else
      flg = 0;
      states = mat(1,nc);
      if any(real(mat(2:nr-1,nc))) | any(imag(mat(2:nr-1,nc))) | ...
         any(real(mat(nr,1:nc-1))) | any(imag(mat(nr,1:nc-1)))
         flg = -2;
      elseif states < 0 | mat(nr,nc) ~= -inf
         flg = -2;
      elseif  floor(states) ~= ceil(states)
         flg = -2;
      elseif states >= min([nr,nc])-1
         flg = -2;
      end
      if flg == 0
         flg = 1;
      else
         npts = mat(nr,max([nc-1,1]));
         if floor(npts) ~= ceil(npts) | npts <= 0
            flg = -3;
         elseif npts >= nr | mat(nr,nc) ~= inf
            flg = -3;
         elseif  any(real(mat(npts+1:nr-1,nc))) | ...
		 any(imag(mat(npts+1:nr-1,nc))) |...
		 any(real(mat(nr,1:nc-2))) | any(imag(mat(nr,1:nc-2)))
            flg = -3;
         end
         if flg == -2
            nrr = round((nr-1)/npts);
		 else
		    nrr = 0;
	     end
         if nrr*npts == nr-1
            flg = 2;
         end
      end
   end
end
if flg < 0
   disp(['Constant:  ' int2str(nr) ' rows  ' int2str(nc) ' cols'])
elseif flg == 1,
%  System matrix used in mu-tools.
   no = nr-1-states;
   ni = nc-1-states;
   lab1 = ['system matrix used in mu-tools:   '];
   lab2 = [int2str(states) ' states     '];
   lab3 = [int2str(no) ' outputs     '];
   lab4 = [int2str(ni) ' inputs     '];
   disp([lab1 lab2 lab3 lab4])
elseif flg == 2,
%  Varying matrix.
   cols=nc-1;
   lab1 = ['varying:   '];
   lab2 = [int2str(npts) ' pts     '];
   lab3 = [int2str(nrr) ' rows     '];
   lab4 = [int2str(cols) ' cols     '];
   disp([lab1 lab2 lab3 lab4])
elseif flg == 4,
%  Mod matrix
   disp('This is a matrix in MPC Mod format.');
   label = ['    minfo = [' num2str(mat(1,1)) '  ' num2str(mat(1,2)) '  '  ...
 	    num2str(mat(1,3)) '  ' num2str(mat(1,4)) '  ' num2str(mat(1,5)) ...
	    '  ' num2str(mat(1,6)) '  ' num2str(mat(1,7)) ' ]'];
   disp(label);
   disp(['sampling time = ' num2str(mat(1,1))]);
   disp(['number of states = ' num2str(mat(1,2))]);
   disp(['number of manipulated variable inputs	= ' num2str(mat(1,3))]);
   disp(['number of measured disturbances 	= ' num2str(mat(1,4))]);
   disp(['number of unmeasured disturbances 	= ' num2str(mat(1,5))]);
   disp(['number of measured outputs 		= ' num2str(mat(1,6))]);
   disp(['number of unmeasured outputs 		= ' num2str(mat(1,7))]);
elseif flg == 5,
%  Step matrix
   disp('This is a matrix in MPC Step format.')
   disp(['sampling time	= ' num2str(mat(nr,1))]);
   disp(['number of inputs	= ' int2str(nc)]);
   disp(['number of outputs	= ' int2str(ny)]);
   disp(['number of step response coefficients = ' int2str(ncoe)]);
   label1 = ['      '];
   label2 = ['      '];
   count = 0;
   for i =1:ny,
      if nout(i) == 0,
         label1 = [label1  'output # ' int2str(i) '  '];
         count = count + 1;
      else
         label2 = [label2  'output # ' int2str(i) '   '];
      end
   end
   if count == ny,
      disp('All outputs are integrating.')
   elseif count == 0,
      disp('All outputs are stable.')
   else
      disp('The following output(s) is(are) stable:');
      disp(label2);
      disp('The following output(s) is(are) integrating:');
      disp(label1);
   end
end

%  End of function mpcinfo.