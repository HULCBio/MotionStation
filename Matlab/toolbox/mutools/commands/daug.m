% function out = daug(mat1,mat2,mat3...,matN,[memstr])
%
%   Diagonal augmentation of SYSTEM/VARYING/CONSTANT,
%   matrices, currently limited to 9 input matrices.
%
%            |  mat1  0     0    .   0   |
%            |   0   mat2   0    .   0   |
%      out = |   0    0    mat3  .   0   |
%            |   .    .     .    .   .   |
%            |   0    0     0    .  matN |
%
%   memstr is a string variable specifying whether or not
%   to minimize memory usage in executing the command.
%   If memstr = "min_mem" then VARYING matrices are stacked in a
%   for loop.  This is much slower but it uses less memory.
%   Use this feature when manipulating huge experimental data
%   files on machines with limited memory.
%
%   See also: ABV, MADD, MMULT, SBS, SEL, and VDIAG.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = daug(mat1,mat2,mat3,mat4,mat5,mat6,mat7,mat8,mat9,mat10)
 if nargin < 2
   disp('usage: out = daug(mat1,mat2,mat3,...,matN,[memstr])')
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
   disp('usage: out = daug(mat1,mat2,mat3,...,matN,[memstr])')
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
     if (toptype == 'syst' & bottype == 'vary') | ...
          (toptype == 'vary' & bottype == 'syst')
       error('DAUG of SYSTEM and VARYING not allowed')
       return
     end
     zur = zeros(toprows,botcols);
     zll = zeros(botrows,topcols);
     if toptype == 'vary'
       if bottype == 'vary'
%	 both varying
         code = indvcmp(top,bot);
         if code == 1
           [vdt,rpt,indvt] = vunpck(top);
           [vdb,rpb,indvb] = vunpck(bot);
           outr = toprows+botrows;
           outc = topcols+botcols;
	   out = zeros(outr*topnum+1,topcols+botcols+1);
           if memflg,
	     for i = 1:topnum,
	       out((i-1)*outr+1:i*outr,1:outc) = ...
		 [vdt(rpt(i):rpt(i)+toprows-1,:),zur; ...
                 zll,vdb(rpb(i):rpb(i)+botrows-1,:)];
	       end
           else
	     tmp = [reshape(vdt,toprows,topnum*topcols); ...
		   zeros(botrows,topnum*topcols)];
	     tmpp = reshape(tmp,topnum*outr,topcols);
	     tmp = [zeros(toprows,botnum*botcols); ...
		   reshape(vdb,botrows,botnum*botcols)];
	     tmppp = reshape(tmp,botnum*outr,botcols);
	     out(1:outr*topnum,1:topcols+botcols) = [tmpp tmppp];
             end
	   out(outr*topnum+1,topcols+botcols+1) = inf;
	   out(outr*topnum+1,topcols+botcols) = topnum;
	   out(1:topnum,topcols+botcols+1) = indvt;
         else
           error('varying data is inconsistent')
           return
         end
       else
%	 varying constant
         [vdt,rpt,indvt] = vunpck(top);
         outr = toprows+botrows;
         outc = topcols+botcols;
	 out = zeros(outr*topnum+1,topcols+botcols+1);
         if memflg,
	   for i = 1:topnum,
	     out((i-1)*outr+1:i*outr,1:outc) = ...
	       [vdt(rpt(i):rpt(i)+toprows-1,:),zur;zll,bot];
	     end
         else
	   tmp = [reshape(vdt,toprows,topnum*topcols); ...
		 zeros(botrows,topnum*topcols)];
	   tmpp = reshape(tmp,topnum*outr,topcols);
	   tmp = kron(ones(topnum,1),[zur;bot]);
	   out(1:outr*topnum,1:topcols+botcols) = [tmpp tmp];
           end
	 out(outr*topnum+1,topcols+botcols+1) = inf;
	 out(outr*topnum+1,topcols+botcols) = topnum;
	 out(1:topnum,topcols+botcols+1) = indvt;
       end
     elseif toptype == 'cons'
       if bottype == 'vary'
%	 constant varying
         [vdb,rpb,indvb] = vunpck(bot);
         outr = toprows+botrows;
         outc = topcols+botcols;
	 out = zeros(outr*botnum+1,topcols+botcols+1);
         if memflg,
	   for i = 1:botnum,
	     out((i-1)*outr+1:i*outr,1:outc) = ...
	       [top,zur;zll,vdb(rpb(i):rpb(i)+botrows-1,:)];
	     end
         else
	   tmp = [zeros(toprows,botnum*botcols); ...
		 reshape(vdb,botrows,botnum*botcols)];
	   tmpp = reshape(tmp,botnum*outr,botcols);
	   tmp = kron(ones(botnum,1),[top;zll]);
	   out(1:outr*botnum,1:topcols+botcols) = [tmp tmpp];
           end
	 out(outr*botnum+1,topcols+botcols+1) = inf;
	 out(outr*botnum+1,topcols+botcols) = botnum;
	 out(1:botnum,topcols+botcols+1) = indvb;
       elseif bottype == 'cons'
         out = [top zur; zll bot];
       else
         [a,b,c,d] = unpck(bot);
         bb = [zeros(botnum,topcols) b];
         cc = [zeros(toprows,botnum) ; c];
         dd = [top zur ; zll d];
         out = pck(a,bb,cc,dd);
       end
     else
       if bottype == 'cons'
         [a,b,c,d] = unpck(top);
         bb = [b zeros(topnum,botcols)];
         cc = [c ; zeros(botrows,topnum)];
         dd = [d zur ; zll bot];
         out = pck(a,bb,cc,dd);
       else
         [at,bt,ct,dt] = unpck(top);
         [nrat,dum] = size(at);
         [ab,bb,cb,db] = unpck(bot);
         [nrab,dum] = size(ab);
         a = [at zeros(nrat,nrab) ; zeros(nrab,nrat) ab];
         b = [bt zeros(nrat,botcols) ; zeros(nrab,topcols) bb];
         c = [ct zeros(toprows,nrab) ; zeros(botrows,nrat) cb];
         d = [dt zur ; zll db];
         out = pck(a,b,c,d);
       end
     end
   end
 else
   exp = ['out=daug(daug('];
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