% function mprintf(mat,form,endline)
%
%   Uses MATLAB function FPRINTF to display real part of matrices.
%     inputs:
%             MAT  -  matrix to be printed
%             FORM -  format, see MATLAB manual for SPRINTF and
%                     FPRINTF, default is '%2.1e '.  (optional)
%             ENDLINE - characters to go at end of line,
%		        default is '\n' (optional)
%
%   See also: DISPLAY, FPRINTF, SPRINTF, SEE, and SEESYS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function mprintf(mat,form,endline)
%
 if nargin == 0
   disp(['usage: mprintf(mat,form,endline)']);
   return
  elseif nargin == 1
   endline='\n';
   form = '%2.1e ';
   pad = ' ';
  else
	loc=find(form=='.')-find(form=='%');
	if isempty(loc), loc=1; end
	if any(form=='e') & loc==1
	    pad = ' ';
	else
	    pad = [];
	end %if any
	if nargin ==2
		endline='\n';
	end %if nargin
 end % if nargin
% echo on

[nr,nc] = size(mat);

for i = 1:nr
	for j = 1:nc
		if mat(i,j) < 0
			fprintf(form,mat(i,j))
		else
			fprintf([pad form], abs(mat(i,j)))
		end
	end
	fprintf(endline);
end
%
%