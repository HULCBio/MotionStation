f=quad('sin',0,pi), correct_ans=2
%f=quad8('sin',0,pi), correct_ans=2
f=quadg('sin',0,pi), correct_ans=2
f=quadg('sin',0,pi,1e-13), correct_ans=2  % with tighter tolerence

f=quadg('fxpow',0,2,[],[],1), correct_ans=2
f=quadg('fxpow',0,2,[],[],2), correct_ans=8/3

%zero_count;
%f=quad('fxpow',0,2,[],[],3), correct_ans=4
%num_functs_in_quad =zero_count
%f=quad8('fxpow',0,2,[],[],3), correct_ans=4
%num_functs_in_quad8 =zero_count
%f=quadg('fxpow',0,2,[],[],3), correct_ans=4
%num_functs_in_quadq =zero_count
%disp('quadg has lowest number of function calls')

%f=quad('fxpow',0,2,[],[],4), correct_ans=32/5
%f=quad8('fxpow',0,2,[],[],4), correct_ans=32/5
f=quadg('fxpow',0,2,[],[],4), correct_ans=32/5

f=quadg('fxpow',0,2,[],[],5), correct_ans=32/3
f=quadg('fxpow',0,2,[],[],6), correct_ans=128/7
f=quadg('fxpow',0,2,[],[],7),correct_ans=32
f=quadg('fxpow',0,2,[],[],8),correct_ans=512/9
f=quadg('fxpow',0,2,[],[],9),correct_ans=512/5

%f=quad8('fxpow',0,2,[],[],10),correct_ans=2048/11
f=quadg('fxpow',0,2,[],[],10),correct_ans=2048/11
