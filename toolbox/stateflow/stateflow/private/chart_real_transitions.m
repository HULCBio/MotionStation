function trans = chart_real_transitions(chart)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/04/15 00:56:08 $

trans = sf('get',chart,'chart.transitions');
simtrans = sf('find',trans,'transition.type','SIMPLE');
supertrans = sf('find',trans,'transition.type','SUPER');
trans = [simtrans,supertrans];