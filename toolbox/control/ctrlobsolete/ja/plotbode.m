% PLOTBODE   プロット用のデータを与えて、Bode 応答をプロット
% 
%    [MPaxes,SubAxes] = PLOTBODE(MAG,PHASE,W,P,M,fig,Gm,Pm,Wgm,Wpm)
% 
% MPaxes  は、2 行 1 列で、SubAxes は、COL 行 2 列で、MAG とPHASE は、
% N 行 COL 列、w は、N 行 1 列、COL は、P 行 M 列です。Gm,Pm,Wgm,Wpm  は、
% 長さ COL(または、空)のベクトルで、PlotToSameAxes は、ブーリアン(1または
% 0)です。


%       Author(s): A. Potvin, 11-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:15 $
