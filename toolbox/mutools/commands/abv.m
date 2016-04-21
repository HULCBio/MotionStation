% function out = abv(mat1,mat2,mat3...,matN,[memstr])
%
%   Stacks VARYING/SYSTEM/CONSTANT matrices above one another:
%
%                          |  mat1  |
%                          |  mat2  |
%            out    =      |  mat3  |
%                          |   ..   |
%                          |  matN  |
%
%   memstr is a string variable specifying whether or not
%   to minimize memory usage in executing the command.
%   If memstr = "min_mem" then VARYING matrices are stacked in a
%   for loop.  This is much slower but it uses less memory.
%   Use this feature when manipulating huge experimental data
%   files on machines with limited memory.
%
%   See also: MADD, DAUG, MMULT, SBS, SEL, and VDIAG.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = abv(mat1,mat2,mat3,mat4,mat5,mat6,mat7,mat8,mat9,mat10)
 if nargin < 2
   disp('usage: out = abv(mat1,mat2,mat3,...,matN,[memstr])')
   return
 else
   str = ['lastarg = mat' int2str(nargin) ';'];
   eval(str)
   end

 memflg = 0;
 if isstr(lastarg),
   nmatargs = nargin-1;
   if strcmp(lastarg,'min_mem'),
     memflg = 1;
     end
 else
   nmatargs = nargin;
   end

 if nmatargs < 2,
   disp('usage: out = abv(mat1,mat2,mat3,...,matN,[memstr])')
   return
 elseif nmatargs == 2
   top = mat1;
   bot = mat2;
   if isempty(top)
     out = bot;
   elseif isempty(bot)
     out = top;
   else
     [toptype,toprows,topcols,topnum] = minfo(top);
     [bottype,botrows,botcols,botnum] = minfo(bot);
     if (bottype == 'syst' & toptype == 'vary') | ...
                (bottype == 'vary' & toptype == 'syst')
       error('ABV of SYSTEM and VARYING not allowed')
       return
     end
     if topcols ~= botcols
       error('incompatible column (input) dimensions')
       return
     end
     if toptype == 'vary'
       if bottype == 'vary'
%	 both VARYING
         code = indvcmp(top,bot);
         if code == 1
           [vdt,rpt,indvt] = vunpck(top);
           [vdb,rpb,indvb] = vunpck(bot);
           outr = toprows+botrows;
	   out = zeros(outr*topnum+1,topcols+1);
           if memflg,
	     for i = 1:topnum,
	       out((i-1)*outr+1:i*outr,1:topcols) = ...
		 [vdt(rpt(i):rpt(i)+toprows-1,:); ...
                 vdb(rpb(i):rpb(i)+botrows-1,:)];
	       end
           else
	     tmp = [reshape(vdt,toprows,topnum*topcols); ...
		   reshape(vdb,botrows,botnum*botcols)];
	     out(1:outr*topnum,1:topcols) = ...
		   reshape(tmp,topnum*outr,topcols);
             end
	   out(outr*topnum+1,topcols+1) = inf;
	   out(outr*topnum+1,topcols) = topnum;
 	   out(1:topnum,topcols+1) = indvt;
         else
           error('varying data is inconsistent')
           return
         end
       else
%	 VARYING above CONSTANT
         [vdt,rpt,indvt] = vunpck(top);
         outr = toprows+botrows;
	 out = zeros(outr*topnum+1,topcols+1);
         if memflg,
	   for i = 1:topnum,
	     out((i-1)*outr+1:i*outr,1:topcols) = ...
	       [vdt(rpt(i):rpt(i)+toprows-1,:);bot];
	     end
         else
	   tmp = [reshape(vdt,toprows,topnum*topcols); ...
		 kron(bot,ones(1,topnum))];
	   out(1:outr*topnum,1:topcols) = ...
		   reshape(tmp,topnum*outr,topcols);
           end
	 out(outr*topnum+1,topcols+1) = inf;
	 out(outr*topnum+1,topcols) = topnum;
	 out(1:topnum,topcols+1) = indvt;
       end
     elseif toptype == 'cons'
       if bottype == 'vary'
         [vdb,rpb,indvb] = vunpck(bot);
         outr = toprows+botrows;
	 out = zeros(outr*botnum+1,topcols+1);
         if memflg,
	   for i = 1:botnum,
	     out((i-1)*outr+1:i*outr,1:topcols) = ...
	       [top;vdb(rpb(i):rpb(i)+botrows-1,:)];
	     end
         else
	   tmp = [kron(top,ones(1,botnum)); ...
		 reshape(vdb,botrows,botnum*topcols)];
	   out(1:outr*botnum,1:topcols) = ...
		 reshape(tmp,botnum*outr,topcols);
           end
	 out(outr*botnum+1,topcols+1) = inf;
	 out(outr*botnum+1,topcols) = botnum;
	 out(1:botnum,topcols+1) = indvb;
       elseif bottype == 'cons'
         out = [top ; bot];
       else
         [a,b,c,d] = unpck(bot);
         cc = [zeros(toprows,botnum) ; c];
         dd = [top ; d];
         out = pck(a,b,cc,dd);
       end
     else
       if bottype == 'cons'
         [a,b,c,d] = unpck(top);
         cc = [c ; zeros(botrows,topnum)];
         dd = [d ; bot];
         out = pck(a,b,cc,dd);
       else
         [at,bt,ct,dt] = unpck(top);
         [ab,bb,cb,db] = unpck(bot);
         a = daug(at,ab);
         b = [bt ; bb];
         c = [ct zeros(toprows,botnum) ; zeros(botrows,topnum) cb];
         d = [dt;db];
         out = pck(a,b,c,d);
       end
     end
   end
 else
%  recursive call for more than two input arguments
   exp = ['out=abv(abv('];
   for i=1:nmatargs-2
     exp=[exp 'mat' int2str(i) ','];
   end
   if memflg,
     mstr = 'min_mem';
     exp = [exp 'mat' int2str(nmatargs-1) ',mstr),mat' ...
		int2str(nmatargs) ',mstr);'];
   else
     exp = [exp 'mat' int2str(nmatargs-1) '),mat' int2str(nmatargs) ');'];
     end
   eval(exp);
 end