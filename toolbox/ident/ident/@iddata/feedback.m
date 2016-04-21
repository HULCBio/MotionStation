function [fbck,fbck0,nudir] = feedback(d)
%IDDATA/FEEDBACK Test possible output feedback in data.
%
%   [FBCK,FBCK0,NUDIR] = FEEDBACK(DATA)
%
%   DATA: AN IDDATA object.
%   FBCK is an Ny-by-Nu matrix indicating the feedback.
%        The ky-by-ku entry is a measure of feedback from output
%        ky to input ku. The value is a probability P in percent.
%        Its iterpretation is that the hypothesis that there is no
%        feedback from ky to ku would be tested at the level P, it
%        be rejected. Thus, the larger the P the greater the indication of
%        feedback. Often only values over 90% would be taken as clear
%        indications. In this test a direct dependence of  u(t) on y(t)
%        (a "direct term") id not viewed as a feedback effect.
%   FBCK0: same as FBCK but this test views direct terms as feedback
%        effects.
%
%   NUDIR is a vector containing those input numbers that appear to have
%       a direct effect on some of the outputs, i.e. no delay from input
%       to output.
%    
%   See also IDDATA/ADVICE.

%   L. Ljung 11-01-02
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:15:49 $

ped = pexcit(d);
if ped<=4
    warning(sprintf(['The input is exciting of order less than 4.',...
            '\nNo formal feedback test can be carried out then, but the',...
            '\nlow degree of excitation is a sign of no feedback.']))
    fbck = 0 ; fbck0 = 0; nudir = [];
    return
end
was = warning;
warning off
[y,t,ysd]=impulse(impulse(d)); %check pe order first
warning(was)
t0=find(t==0);
[lt,ny,nu] = size(y);
dirterm = zeros(ny,nu);
fbck = zeros(ny,nu);
fbck0 = fbck;
for ky=1:ny
    for ku=1:nu
        y0=y(t0,ky,ku);
        if abs(y0)>3*ysd(t0,ky,ku)
            dirterm(ky,ku)=1;
        end
       fbck(ky,ku) = 100*idchi2(sum((y(find(t<0),ky,ku)./ysd(find(t<0),ky,ku)).^2),...
           length(find(t<0)));
       fbck0(ky,ku) = 100*idchi2(sum((y(find(t<=0),ky,ku)./ysd(find(t<=0),ky,ku)).^2),...
           length(find(t<=0)));
    end
end

nudir = find(sum(dirterm==1));
