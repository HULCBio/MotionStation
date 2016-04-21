function [s1,s2,s3,s4,s5,s6,s7,s8]=triphazicon(name,a,b,c)
%
%TRIPHAZICON is used to build the icon for triphase blocks of powerlib_extras
%            library.
%
%   Patrice Brunelle 20-11-97
%   Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

short_x =[0,150];
short_y =[0,0];
 
resistor_x = [0 30,30,38,53,68,83,98,113,120,120,150];
resistor_y = [0,0,0,25,-25,25,-25,25,-25,0,0,0];

inductor_x = [150,173,173,174,178,184,190,197,202,205,206,204,201,201,197,196,198,201,207,214,220,225,229,229,227,224,224,220,219,221,225,230,237,243,249,252,253,251,247,247,244,243,244,248,254,260,267,272,275,276,276,300];

inductor_y = [0,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1, 11,19,24,25,23,17,8,0,0,0];

capacitor_x1 = [300 360 360 360];
capacitor_y1 = [0 0 25 -25];
capacitor_x2 = [390 390 390 450];
capacitor_y2 = [25,-25,0,0];



switch name

case '3-phase series RLC load'
if a~=0
	s1=resistor_x;
	s2=resistor_y;
else
	s1=short_x;
	s2=short_y;
end

if b~=0
	s3=inductor_x;
	s4=inductor_y;
else
	s3=short_x+150;
	s4=short_y;
end

if c~=0
	s5=capacitor_x1;
	s6=capacitor_y1;
	s7=capacitor_x2;
	s8=capacitor_y2;
else
	s5=short_x+300;
	s6=short_y;
	s7=[];
	s8=[];
end

if a==0&b==0&c==0
	s3=[];
	s4=[];
end



case '3-phase RLC series element'


if a==inf,
	errordlg('R parameter must have a finite value');
end
if b==inf,
	errordlg('L parameter must have a finite value');
end
if c==0,
	errordlg('C parameter must be greater than zero');
end

if a~=0
	s1=resistor_x;
	s2=resistor_y;
else
	s1=short_x;
	s2=short_y;
end

if b~=0
	s3=inductor_x;
	s4=inductor_y;
else
	s3=short_x+150;
	s4=short_y;
end

if c~=inf
	s5=capacitor_x1;
	s6=capacitor_y1;
	s7=capacitor_x2;
	s8=capacitor_y2;
else
	s5=short_x+300;
	s6=short_y;
	s7=[];
	s8=[];
end

if a==0&b==0&c==inf
	s3=[];
	s4=[];
end


case '3-phase inductive source'


if a~=0
	s1=resistor_x;
	s2=resistor_y;
else
	s1=short_x;
	s2=short_y;
end

if b~=0
	s3=inductor_x;
	s4=inductor_y;
else
	s3=short_x+150;
	s4=short_y;
end

s5=[];
s6=[];
s7=[];
s8=[];

end




