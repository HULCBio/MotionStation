% PDECGRAD   PDE �̉��̃t���b�N�X c*grad(u) �̌v�Z
%
% [CGXU,CGYU] = PDECGRAD(P,T,C,U) �́A�e�O�p�`�̒��_�ŉ��߂��ꂽ�t���b�N
% �X c*grad(u) ���o�͂��܂��B
%
% PDE ���̌`��́A�O�p�`�f�[�^ P �� T �ɂ���ė^�����܂��B�ڍׂ́A
% INITMESH ���Q�Ƃ��Ă��������B
%
% PDE ���̌W�� C �́A���푽�l�ȕ��@�ŗ^���邱�Ƃ��ł��܂��B�ڍׂ́A
% ASSEMPDE ���Q�Ƃ��Ă��������B
%
% ���x�N�g�� U �̃t�H�[�}�b�g�́AASSEMPDE �ɋL�q����Ă��܂��B
%
% �W�� C �����ԂɈˑ�����ꍇ�́A[CGXU,CGYU] = PDECGRAD(P,T,C,U,TIME) ��
% �Ȃ�܂��BTIME �́A�����ł��B
%
% [CGXU,CGYU] = PDECGRAD(P,T,C,U,TIME,SDL) �́A���X�g SLD �ɂ���T�u�h��
% �C���Ɍv�Z�𐧌����܂��B
%
% �Q�l   ASSEMPDE, INITMESH, PDEGRAD



%       Copyright 1994-2001 The MathWorks, Inc.
