% DNICHOLS   ���U���Ԑ��`�V�X�e���ɑ΂��� Nichols���g������
%
% DNICHOLS(A,B,C,D,Ts,IU) �́A���U��ԋ�ԃV�X�e�� (A, B, C, D) �̒P���� 
% IU ���炷�ׂĂ̏o�͂ւ� Nichols���}���쐬���܂��BIU �́A�V�X�e����
% ���͂̒����� Nichols�������v�Z���邽�߂Ɏg�p������͂�I�����邽�߂�
% �C���f�b�N�X�ł��BTs �̓T���v�������ł��B���g���͈̔͂Ɠ_���́A�����I��
% ���߂��܂��B
%
% DNICHOLS(NUM,DEN,Ts) �́A�������`�B�֐� G(z) = NUM(z)/DEN(z) �ɑ΂��� 
% Nichols���}���쐬���܂��B�����ŁANUM �� DEN �́A�������̌W���� z ��
% �~�x�L�̏��ɕ��ׂ����̂ł��B
%
% DNICHOLS(A,B,C,D,Ts,IU,W) �܂��́ADNICHOLS(NUM,DEN,Ts,W) �́ANichols����
% ���v�Z������g���� rad/sec �P�ʂŃ��[�U���ݒ肵�����g���x�N�g�� W ��
% �g�p���܂��B�G���A�W���O�́ANyquist���g��(pi/Ts)��荂�����g���Ő����܂��B
% ���ӂ̈�����ݒ肵�Ȃ��ꍇ�A
% 
%            [MAG,PHASE,W] = DNICHOLS(A,B,C,D,Ts,...)
%            [MAG,PHASE,W] = DNICHOLS(NUM,DEN,Ts,...) 
% 
% ���g���x�N�g�� W �ƍs�� MAG �� PHASE(�P�ʓx)���o�͂��܂��B�����́A
% �o�͂Ɠ����񐔂������Alength(W) �Ɠ������s���������Ă��܂��B�X�N���[����
% �Ƀv���b�g�\���͍s���܂���BNichols �O���b�h�́ANGRID ���g���ĕ`��
% ���Ƃ��ł��܂��B 
%
% �Q�l : LOGSPACE, SEMILOGX, MARGIN, DBODE, DNYQUIST.


%       Clay M. Thompson 7-10-90
%       Revised ACWG 2-12-91, 6-21-92
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:52 $
