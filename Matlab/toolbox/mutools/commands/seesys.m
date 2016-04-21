% function seesys(mat,form)
%
%   Uses MATLAB function FPRINTF to print real part of matrices.
%   Primarily intended for printing system matrices.
%     inputs
%            MAT   - matrix to be printed
%            FORM  - format, see MATLAB manual for SPRINTF and FPRINTF
%
%   See also: DISP, FPRINTF, GETIV, MPRINTF, SEE, SEEIV,
%             SORTIV,and SPRINTF.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function seesys(mat,form,formw)
%
 if nargin == 0
   disp(['usage: seesys(mat,form,formw)']);
   return
  elseif nargin ==1
   form = '%.1e ';
 end
% echo on

[mtype,mrows,mcols,mnum] = minfo(mat);

if mtype=='cons'
	mprintf(mat,form)
elseif mtype=='syst'
    i1 = [1 mnum+1]; i2 = [mnum mnum+mrows];
    fprintf('\n');
    str=[];str1=[];str2=[];
    for ii = 1:2
	str=[str1 str2];
	if length(str) > 0
	  fprintf(str);
        end
	for i = i1(ii):i2(ii)
	    str = [];
		for j = 1:mnum
			str = [str seesub(mat(i,j),form)];
		end
		str1=[ setstr('-'*ones(1,length(str)+1)) '|'];
		str = [str ' | ' ];
		for j = (mnum+1) : (mnum+mcols)
			str = [str seesub(mat(i,j),form)];
		end
		fprintf([str '\n'])
		str2 = [ setstr('-'*ones(1,length(str)-length(str1)-1)) '\n'];
	end
    end
elseif mtype == 'vary'
   if nargin <= 2
     formw = '%g ';
   end
   [nr,nc] = size(mat);
   place = 1;
   omega = mat(1:mnum,nc);
   if mrows > 1
     if mcols > 1
       fprintf('%.0f rows  %.0f columns\n',mrows,mcols)
     else
       fprintf('%.0f rows  %.0f column\n',mrows,mcols)
     end
   else
     if mcols > 1
       fprintf('%.0f row  %.0f columns\n',mrows,mcols)
     else
       fprintf('%.0f row  %.0f column\n',mrows,mcols)
     end
   end
   fprintf('\n')
   for i=1:mnum
     fprintf(['iv  = ' formw '\n'],omega(i))
     mprintf(mat(place:place+mrows-1,1:mcols),form)
     place = place + mrows;
     fprintf('\n');
   end

end
fprintf('\n')
%
%