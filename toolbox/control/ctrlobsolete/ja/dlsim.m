% DLSIM   ���U���Ԑ��`�V�X�e���̃V�~�����[�V����
%
% DLSIM(A,B,C,D,U) �́A���U�V�X�e�� 
%
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% �ɓ��͗� U ��K�p�����ꍇ�̎��ԉ������v���b�g���܂��B�s�� U �́A���� u 
% �̐��Ɠ����񐔂������Ă��܂��BU �̊e�s�́A�v�Z����V�������ԓ_�ɑΉ�
% ���܂��BDLSIM(A,B,C,D,U,X0) �́A�������� X0 ���ݒ肳��Ă���ꍇ��
% �g�p���܂��B
%
% DLSIM(NUM,DEN,U) �́A�`�B�֐��L�q G(z) = NUM(z)/DEN(z) �̎��ԉ�����
% �v���b�g���܂��B�����ŁANUM �� DEN �́A�������̌W���ŁAz �̍~�x�L��
% ���ɕ��ׂ����̂ł��BLENGTH(NUM) = LENGTH(DEN) �̏ꍇ�ADLSIM(NUM,DEN,U) 
% �́AFILTER(NUM,DEN,U) �Ɠ����ł��B���ӂɈ�����ݒ肵�Ă��Ȃ��ꍇ�A
% 
%    [Y,X] = DLSIM(A,B,C,D,U)
%    [Y,X] = DLSIM(NUM,DEN,U)
% 
% �s�� Y �� X �ɏo�͂Ə�Ԃ̎��n����o�͂��A�X�N���[����Ƀv���b�g��
% �s���܂���BY �́A�o�͐��Ɠ����񐔂ŁALENGTH(U)�̍s���������Ă��܂��B
% X �́A��Ԑ��Ɠ����񐔂ŁALENGTH(U) �Ɠ����s���������Ă��܂��B
%
% �Q�l : LSIM, STEP, IMPULSE, INITIAL.


%   J.N. Little 4-21-85
%   Revised 7-18-88 JNL
%   Revised 7-31-90  Clay M. Thompson
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:49 $
