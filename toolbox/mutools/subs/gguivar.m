% function [varval1,varval2,varval3,varval4,varval5,varval6] = ...
%     gguivar(varname1,varname2,varname3,varname4,varname5,varname6,varname7)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [varval1,varval2,varval3,varval4,varval5,varval6] = ...
    gguivar(varname1,varname2,varname3,varname4,varname5,varname6,varname7)

    lastarg = ['varname' int2str(nargin)];
    eval(['h = isstr(' lastarg ');']);
    if h==1
        mh = unique([gcbf gcf]);
        if length(mh) > 1
	    [ours,othw,theirs,splts] = findmuw(mh);
	    if ~isempty(ours) & ~isempty(theirs)	% DEMO creates wsgui
	        mh = ours;
	    elseif isempty(theirs)			% both MU tools
		mh = gcbf;
	    else
	        error('Cannot find a mutools GUI.  Please report this bug.');
	    end
	end
        nargina = nargin;
    else
        eval(['mh = ' lastarg ';']);
        nargina = nargin - 1;
    end

    allhandles = get(mh,'userdata');
    anames = get(allhandles(1),'userdata');
    pimnum = get(allhandles(2),'userdata');

    if nargina == 1
        index1 = h2v(anames,pimnum,varname1);
        varval1 = xpii(get(allhandles(index1(1)),'Userdata'),index1(2));
    elseif nargina == 2
        [index1,index2] = h2v(anames,pimnum,varname1,varname2);
        varval1 = xpii(get(allhandles(index1(1)),'Userdata'),index1(2));
        varval2 = xpii(get(allhandles(index2(1)),'Userdata'),index2(2));
    elseif nargina == 3
        [index1,index2,index3] = h2v(anames,pimnum,varname1,varname2,varname3);
        varval1 = xpii(get(allhandles(index1(1)),'Userdata'),index1(2));
        varval2 = xpii(get(allhandles(index2(1)),'Userdata'),index2(2));
        varval3 = xpii(get(allhandles(index3(1)),'Userdata'),index3(2));
    elseif nargina == 4
        [index1,index2,index3,index4] = ...
            h2v(anames,pimnum,varname1,varname2,varname3,varname4);
        varval1 = xpii(get(allhandles(index1(1)),'Userdata'),index1(2));
        varval2 = xpii(get(allhandles(index2(1)),'Userdata'),index2(2));
        varval3 = xpii(get(allhandles(index3(1)),'Userdata'),index3(2));
        varval4 = xpii(get(allhandles(index4(1)),'Userdata'),index4(2));
    elseif nargina == 5
        [index1,index2,index3,index4,index5] = ...
            h2v(anames,pimnum,varname1,varname2,varname3,varname4,varname5);
        varval1 = xpii(get(allhandles(index1(1)),'Userdata'),index1(2));
        varval2 = xpii(get(allhandles(index2(1)),'Userdata'),index2(2));
        varval3 = xpii(get(allhandles(index3(1)),'Userdata'),index3(2));
        varval4 = xpii(get(allhandles(index4(1)),'Userdata'),index4(2));
        varval5 = xpii(get(allhandles(index5(1)),'Userdata'),index5(2));
    elseif nargina == 6
        [index1,index2,index3,index4,index5,index6] = ...
            h2v(anames,pimnum,varname1,varname2,varname3,varname4,varname5,varname6);
        varval1 = xpii(get(allhandles(index1(1)),'Userdata'),index1(2));
        varval2 = xpii(get(allhandles(index2(1)),'Userdata'),index2(2));
        varval3 = xpii(get(allhandles(index3(1)),'Userdata'),index3(2));
        varval4 = xpii(get(allhandles(index4(1)),'Userdata'),index4(2));
        varval5 = xpii(get(allhandles(index5(1)),'Userdata'),index5(2));
        varval6 = xpii(get(allhandles(index6(1)),'Userdata'),index6(2));
    end