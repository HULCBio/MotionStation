%function [freq,mag] = terpol(freqin,magin,npts)
%
% この関数は、不定間隔の周波数/ゲインデータFRQINおよびMAGINを以下の方法
% で内挿します。最初に、FREQINは、0からπの間の非負の周波数からなる行ベ
% クトルであると仮定します。
% 
% 1 <= i <= NPTSであるiに対して
%    pi*(i-1)/NPTS  <  FREQIN(1)の場合、FREQ(i)  :=  MAG(1)になります。
%    FREQIN(length(FREQIN))  <=  pi*(i-1)/NPTSの場合、MAGOUT((i) =  
%    MAGIN(length(MAGIN))になります。
%    他のFREQIN(i)の値については、プログラムはデータ点間の線形内挿を行い
%    ます。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:59 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
