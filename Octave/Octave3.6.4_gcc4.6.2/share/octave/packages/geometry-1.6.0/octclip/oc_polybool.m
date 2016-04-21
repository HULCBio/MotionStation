## Copyright (C) 2011, José Luis García Pallero, <jgpallero@gmail.com>
##
## This file is part of OctCLIP.
##
## OctCLIP is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File}{[@var{X},@var{Y},@var{nPol},@var{nInt},@var{nPert}] =}oc_polybool(@var{sub},@var{clip},@var{op})
## @deftypefnx{Function File}{[@var{X},@var{Y},@var{nPol},@var{nInt},@var{nPert}] =}oc_polybool(@var{sub},@var{clip})
##
## This function performs boolean operations between two polygons using the
## Greiner-Hormann algorithm (http://davis.wpi.edu/~matt/courses/clipping/).
##
## @var{sub} is a two column matrix containing the X and Y coordinates of the
## vertices for the subject polygon.
##
## @var{clip} is a two column matrix containing the X and Y coordinates of the
## vertices for the clipper polygon.
##
## @var{op} is a text string containing the operation to perform between
## @var{sub} and @var{clip}. Possible values are:
##
## @itemize @bullet
## @item @var{'AND'}
## Intersection of @var{sub} and @var{clip} (value by default).
## @item @var{'OR'}
## Union of @var{subt} and @var{clip}.
## @item @var{'AB'}
## Operation @var{sub} - @var{clip}.
## @item @var{'BA'}
## Operation of @var{clip} - @var{sub}.
## @end itemize
##
## For the matrices @var{sub} and @var{clip}, the first point is not needed to
## be repeated at the end (but is permitted). Pairs of (NaN,NaN) coordinates in
## @var{sub} and/or @var{clip} are ommitted.
##
## @var{X} is a column vector containing the X coordinates of the vertices of
## the resultant polygon(s).
##
## @var{Y} is a column vector containing the Y coordinates of the vertices of
## the resultant polygon(s).
##
## @var{nPol} is the number of output polygons.
##
## @var{nInt} is the number of intersections between @var{sub} and @var{clip}.
##
## @var{nPert} is the number of perturbed points of the @var{clip} polygon in
## any particular case (points in the oborder of the other polygon) occurs see
## http://davis.wpi.edu/~matt/courses/clipping/ for details.
## @end deftypefn




function [X,Y,nPol,nInt,nPert] = oc_polybool(sub,clip,op)

try
    functionName = 'oc_polybool';
    minArg = 2;
    maxArg = 3;

#*******************************************************************************
#NUMBER OF INPUT ARGUMENTS CHECKING
#*******************************************************************************

    #number of input arguments checking
    if (nargin<minArg)||(nargin>maxArg)
        error(['Incorrect number of input arguments (#d)\n\t         ',...
               'Correct number of input arguments = #d or #d'],...
              nargin,minArg,maxArg);
    end
    #check if we omit the op argument
    if nargin==minArg
        #by default, use AND
        op = 'AND';
    end

#*******************************************************************************
#INPUT ARGUMENTS CHECKING
#*******************************************************************************

    #checking input arguments
    [op] = checkInputArguments(sub,clip,op);
catch
    #error message
    error('\n\tIn function #s:\n\t -#s ',functionName,lasterr);
end

#*******************************************************************************
#COMPUTATION
#*******************************************************************************

try
    #calling oct function
    [X,Y,nPol,nInt,nPert] = _oc_polybool(sub,clip,op);
catch
    #error message
    error('\n\tIn function #s:\n\tIn function #s ',functionName,lasterr);
end




#*******************************************************************************
#AUXILIARY FUNCTION
#*******************************************************************************




function [outOp] = checkInputArguments(sub,clip,inOp)

#sub must be matrix type
if ismatrix(sub)
    #a dimensions
    [rowSub,colSub] = size(sub);
else
    error('The first input argument is not numeric');
end
#clip must be matrix type
if ismatrix(clip)
    #b dimensions
    [rowClip,colClip] = size(clip);
else
    error('The second input argument is not numeric');
end
#checking dimensions
if (colSub~=2)||(colClip~=2)
    error('The columns of input arguments must be 2');
end
#operation must be a text string
if ~ischar(inOp)
    error('The third input argument is not a text string');
else
    #upper case
    outOp = toupper(inOp);
    #check values
    if (~strcmp(outOp,'AND'))&&(~strcmp(outOp,'OR'))&& ...
        (~strcmp(outOp,'AB'))&&(~strcmp(outOp,'BA'))
        error('The third input argument is not correct');
    end
end




#*****END OF FUNCIONS*****




#*****FUNCTION TESTS*****




#tests for input arguments
%!error(oc_polybool)
%!error(oc_polybool(1,2,3,4))
%!error(oc_polybool('string',2,3))
%!error(oc_polybool(1,'string',3))
%!error(oc_polybool(1,2,3))
#demo program
%!demo
%!  #subject polygon
%!  clSub = [9.0 7.5
%!           9.0 3.0
%!           2.0 3.0
%!           2.0 4.0
%!           8.0 4.0
%!           8.0 5.0
%!           2.0 5.0
%!           2.0 6.0
%!           8.0 6.0
%!           8.0 7.0
%!           2.0 7.0
%!           2.0 7.5
%!           9.0 7.5];
%!  #clipper polygon
%!  clClip = [2.5 1.0
%!            7.0 1.0
%!            7.0 8.0
%!            6.0 8.0
%!            6.0 2.0
%!            5.0 2.0
%!            5.0 8.0
%!            4.0 8.0
%!            4.0 2.0
%!            3.0 2.0
%!            3.0 8.0
%!            2.5 8.0
%!            2.5 1.0];
%!  #limits for the plots
%!  clXLim = [1.5 11.75];
%!  clYLim = [0.5  8.50];
%!  #compute intersection
%!  [clXI,clYI] = oc_polybool(clSub,clClip,'and');
%!  #compute union
%!  [clXU,clYU] = oc_polybool(clSub,clClip,'or');
%!  #compute A-B
%!  [clXA,clYA] = oc_polybool(clSub,clClip,'ab');
%!  #compute B-A
%!  [clXB,clYB] = oc_polybool(clSub,clClip,'ba');
%!  #plot window for intersection
%!  subplot(2,2,1);
%!  plot(clXI,clYI,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
%!       clClip(:,1),clClip(:,2));
%!  axis('equal');
%!  xlim(clXLim);
%!  ylim(clYLim);
%!  title('OctCLIP intersection');
%!  legend('Intersection','Subject polygon','Clipper polygon',...
%!         'location','southeast');
%!  #plot window for union
%!  subplot(2,2,2);
%!  plot(clXU,clYU,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
%!       clClip(:,1),clClip(:,2));
%!  axis('equal');
%!  xlim(clXLim);
%!  ylim(clYLim);
%!  title('OctCLIP union');
%!  legend('Union','Subject polygon','Clipper polygon','location','southeast');
%!  #plot window for A-B
%!  subplot(2,2,3);
%!  plot(clXA,clYA,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
%!       clClip(:,1),clClip(:,2));
%!  axis('equal');
%!  xlim(clXLim);
%!  ylim(clYLim);
%!  title('OctCLIP A-B');
%!  legend('A-B','Subject polygon','Clipper polygon','location','southeast');
%!  #plot window for B-A
%!  subplot(2,2,4);
%!  plot(clXB,clYB,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
%!       clClip(:,1),clClip(:,2));
%!  axis('equal');
%!  xlim(clXLim);
%!  ylim(clYLim);
%!  title('OctCLIP B-A');
%!  legend('B-A','Subject polygon','Clipper polygon','location','southeast');
%!  #input message
%!  disp('Press ENTER to continue ...');
%!  pause();
%!  #kill and close the plot window
%!  clf();
%!  close();




#*****END OF TESTS*****
