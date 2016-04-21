% DIMPULSE   ���U���Ԑ��`�V�X�e���̃C���p���X����
%
% DIMPULSE(A,B,C,D,IU) �́A���U�V�X�e��
%
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% �̓��� IU �ɃC���p���X��K�p�����ꍇ�̉������v���b�g���܂��B�������v�Z
% ����_���́A�����I�Ɍ��߂��܂��B
%
% DIMPULSE(NUM,DEN) �́A�������`�B�֐�  G(z) = NUM(z)/DEN(z) �̃C���p���X
% �������v���b�g���܂��B�����ŁANUM �� DEN �́A�������̌W�����~�x�L����
% ���ׂ����̂ł��B
%
% DIMPULSE(A,B,C,D,IU,N) �܂��́ADIMPULSE(NUM,DEN,N) �́A�������v�Z����
% �_�� N ��ݒ肵�܂��B�܂��A���ӂɏo�͈����Ɛݒ肵���ꍇ�A
% 
%    [Y,X] = DIMPULSE(A,B,C,D,...)
%    [Y,X] = DIMPULSE(NUM,DEN,...)
% 
% �s�� Y �� X �ɏo�͂Ə�Ԃ̎��n��f�[�^���o�͂��܂��B�����āA�X�N���[����
% �ɂ̓v���b�g�\������܂���BY �́A�o�͂���鐔�̗񐔂������AX �͏�Ԑ���
% �������̗񐔂������Ă��܂��B
%
% �Q�l : IMPULSE, STEP, INITIAL, LSIM.


%   J.N. Little 4-21-85
%   Revised CMT 7-31-90, ACWG 5-30-91, AFP 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:44 $
