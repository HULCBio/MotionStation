% DBODE   ���U���Ԑ��`�V�X�e���ɑ΂��� Bode ���g������
%
% DBODE(A,B,C,D,Ts,IU) �́A�P���� IU ���痣�U��ԋ�ԃV�X�e��(A, B, C, D)
% �̂��ׂĂ̏o�͂ɑ΂��� Bode �v���b�g���쐬���܂��BIU �́ABode ������
% �g�p������͂��w�肷����͂̃C���f�b�N�X�ł��BTs �́A�T���v�������ł��B
% ���g���ш�Ɠ_���́A�����I�ɑI������܂��B
%
% DBODE(NUM,DEN,Ts) �́A�������`�B�֐� G(z) = NUM(z)/DEN(z) �ɑ΂��� 
% Bode ���}���쐬���܂��B�����ŁANUM �� DEN �́Az �ŕ\�����~�x�L�̏���
% ���ׂ��������W�����܂�ł��܂��B
%
% DBODE(A,B,C,D,Ts,IU,W) �܂��́ADBODE(NUM,DEN,Ts,W) �́A���[�U�w���
% ���g���x�N�g�� W ���g���܂��B���̃x�N�g���́Arad/sec �P�ʂŁABode ������
% �v�Z����ʒu��\���܂��B�G���A�W���O�́ANyquist ���g��(pi/T)�ȏ�̎��g����
% �����܂��B�ΐ��Ԋu�̎��g���x�N�g�����쐬����ɂ́ALOGSPACE ���Q�Ƃ���
% ���������B���̂悤�ɁA
% 
%    [MAG,PHASE,W] = DBODE(A,B,C,D,Ts,...)
%    [MAG,PHASE,W] = DBODE(NUM,DEN,Ts,...) 
% 
% ���ӂɈ�����ݒ肷��ƁA���g���x�N�g�� W �ƍs�� MAG �� PHASE(�P�ʂ͓x)��
% �o�͂��܂��B���̍s��́Alength(W) �s�������܂��B�܂��A���̃X�e�[�g�����g
% �ł́A�X�N���[����Ƀv���b�g��\�����܂���B
%
% �Q�l : BODE, LOGSPACE, SEMILOGX, MARGIN, NICHOLS, NYQUIST.


%   J.N. Little 10-11-85
%   Revised Andy Grace 8-15-89 2-4-91 6-20-92
%   Revised Clay M. Thompson 7-10-90
%   Revised A.Potvin 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:35 $
