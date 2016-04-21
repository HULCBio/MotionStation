% LQG   �A�����Ԑ��`�񎟌`��Gaussian����݌v
%
% [SS_F] = LQG(SS_,W,V)�܂���[AF,BF,CF,DF] = LQG(A,B,C,D,W,V)�́A"��������"
% ����ɁA�]���֐�
%                     T
%    J    = lim E{ int   |x' u'| W |x| dt} , W = |Q  Nc| 
%     LQG   T-->inf   0            |u|           |Nc' R|
%    
% ���ŏ�������A�v�����g
% 
%                       dx/dt = Ax + Bu + xi
%                           y = Cx + Du + th
%
% �ɂ����āA���F�m�C�Y�G��{xi}�����{th}���A
%
%           E{|xi| |xi th|'} = V delta(t-tau), V =  |Xi  Nf|
%             |th|                                  |Nf' Th|
%
% �̂悤�ɋ��xV�̑��ݑ��֊֐������A���`�񎟌`��Gaussian�œK�R���g���[��
% ���v�Z���܂��B 
% 
% LQG�œK�R���g���[��F(s)�́ASS_F�܂���(af,bf,cf,df)�ɏo�͂���܂��B
% �W���̏�ԋ�Ԍ^�́A"branch"�ɂ�苁�߂��܂��B



% Copyright 1988-2002 The MathWorks, Inc. 
