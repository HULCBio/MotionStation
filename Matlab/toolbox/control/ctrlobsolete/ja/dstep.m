% DSTEP   ���U���Ԑ��`�V�X�e���̃X�e�b�v����
%
% DSTEP(A,B,C,D,IU) �́A���U�V�X�e��
%
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% �̒P���� IU �ɃX�e�b�v��K�p�����ꍇ�̉������v���b�g���܂��B���͐��́A
% �����I�Ɍ��܂�܂��B
%
% DSTEP(NUM,DEN) �́A�������`�B�֐� G(z) = NUM(z)/DEN(z) �̃X�e�b�v������
% �v���b�g���܂��B�����ŁANUM �� DEN �́A�������̌W���ŁAz �̍~�x�L�̏���
% ���ׂ����̂ł��B
%
% DSTEP(A,B,C,D,IU,N) �܂��́ADSTEP(NUM,DEN,N) �́A�v�Z������g���_�� 
% N �����[�U���ݒ肵�܂��B���ӂɏo�͈�����ݒ肵�Ȃ��ꍇ�A
% 
%    [Y,X] = DSTEP(A,B,C,D,...)
%    [Y,X] = DSTEP(NUM,DEN,...)
% 
% �s�� Y �� X �ɏo�͂Ə�Ԃ̎��n����o�͂��A�X�N���[����Ƀv���b�g�\��
% ����܂���BY �́A�o�͐��Ɠ����񐔂ŁAX �́A��Ԑ��Ɠ����񐔂�������
% ���܂��B
%
% �Q�l : STEP, IMPULSE, INITIAL, LSIM.


%   J.N. Little 4-21-85
%   Revised JNL 7-18-88, CMT 7-31-90, ACWG 6-21-92
%   Revised A. Potvin 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:57 $
