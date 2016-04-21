% ADAPTMESH   �A�_�v�e�B�u���b�V�����쐬���APDE���������܂��B
%
% [U,P,E,T] = ADAPTMESH(G,B,C,A,F,P1,V1,...) �́A�A�_�v�e�B�u���b�V����
% �쐬���APDE ���������܂��B��蓾����̓I�v�V�����̒��ő傫�����l�́A
% �v���p�e�B�l�̑g�̈������g���Ĉ����܂��B�ŏ���5�̈���G, B, C, A, F
% �́A�I�v�V�����ł͂���܂���B
%
% ���̊֐��́AG �� B �ŗ^����ꂽ���̌`��Ƌ��E�����ɑ΂��āA�ȉ~�^�X
% �J�� PDE ��� -div(c*grad(u))+a*u = f �������܂��B
%
% �� u �́AMATLAB �̗�x�N�g�� U �Ƃ��ĕ\�킳��܂��B�ڍׂ́AASSEMPDE ��
% �Q�Ƃ��Ă��������B
%
% G �́APDE ���̌`���\�킵�܂��BG �́ADecomposed Geometry �s��܂���
% Geometry M-�t�@�C���̃t�@�C�����̂ǂ���ł��\�ł��B�ڍׂ́ADECSG ��
% ���́APDEGEOM���Q�Ƃ��Ă��������B
%
% B �́APDE ���̋��E������\�킵�܂��BB�́ABoundary Condition �s��A��
% ���́ABoundary M-�t�@�C���̃t�@�C�����̂ǂ���ł��\�ł��B�ڍׂ́APDE
% BOUND ���Q�Ƃ��Ă��������B
%
% PDE ���̃A�_�v�e�B�u�O�p�`���b�V���́A�O�p�`�f�[�^P, E, T �ɂ���ė^
% �����܂��B�ڍׂ́AINITMESH �܂��� PDEGEOM���Q�Ƃ��Ă��������B
%
% PDE ���̌W�� C, A, F �́A���L�����l�ȕ��@�ŗ^�����܂��B�ڍׂ́A
% ASSEMPDE ���Q�Ƃ��Ă��������B
%
% �L���ȃv���p�e�B/�l�̑g���킹���ȉ��Ɏ����܂��B
%
%     �v���p�e�B   �l/{�f�t�H���g}         �ڍ�
% --------------------------------------------------------------------
%     Maxt        ���̐���{Inf}           �V�����O�p�`�̍ő吔
%     Ngen        ���̐���{10}            �O�p�`�����̍ő��
%     Mesh        P1, E1, T1              �������b�V��
%     Tripick     pdeadworst}|pdeadgsc    �O�p�`�̑I����@
%     Par         ���l{0.5}               �֐��p�����[�^
%     Rmethod     {longest}|regular       �O�p�`�̍ו������@
%     Nonlin      on | off                ����`�\���o�̎g�p
%     Toln        ���l{1e-3}              ����`�̌덷
%     Init        ������|���l             ����`�̏����̉��̒l
%     Jac         {fixed}|lumped|full     ����`�\���o�̃��R�r�A���v�Z
%     Norm        ���l{Inf}               ����`�\���o�̎c���m����
%
% Par �́Atripick �֐��ɓn����܂��B�ʏ�́A�����ǂ̂��炢�ǂ��������ɓK
% �����Ă��邩�̋��e�͈͂Ƃ��Ďg���܂��BNgen �ȏ�̘A���I�ȍו����́A
% �s���܂���B�ו����́A���b�V����̎O�p�`�̐��� Maxt ���z�����Ƃ��ɂ�
% �~�܂�܂��B
%
% P1, E1, T1 �́A���̓��b�V���f�[�^�ł��B���̎O�p�`���b�V���́A�A�_�v�e
% �B�u�A���S���Y���ŏ������b�V���Ƃ��Ďg���܂��B�������b�V����^���Ȃ�
% ��΁A�I�v�V���������̂Ȃ� INITMESH �����s����A���̌��ʂ��������b�V��
% �Ƃ��Ďg���܂��B
%
% �O�p�`�̑I����@�́A���[�U����`�����O�p�`�̑I����@�ł��B�֐�PDEJMPS
% �ɂ���Čv�Z���ꂽ�덷�]����^����ƁA�O�p�`�̑I����@�́A���̎O�p�`
% �����ōו�������O�p�`��I�����܂��B�֐��́A���� P, T, CC, AA, FF, U, 
% ERRF, PAR �Ƌ��ɌĂэ��܂�܂��BP �� T �́A�J�����g�̎O�p�`�̐�����\
% �킵�܂��BCC, AA, FF�́APDE ���̃J�����g�W���ŁA�O�p�`�̒��_�Ɋg����
% ��܂��BU �́A�J�����g�̉��ł��BERRF �́A�v�Z���ꂽ�덷�]���ł��B�֐�
% �p�����[�^ PAR �́A�I�v�V�����̈����Ƃ��āAADAPTMESH �ɗ^�����܂��B
% �s�� CC, AA, FF, ERRF �́A�S�� NT ��ł��B�����ŁANT �́A�J�����g�̎O
% �p�`�̐��ł��BCC, AA, FF �̍s�̐��́A���͈��� C, A, F �ƑS�������ł��B
% ERRF �́A�V�X�e���̒��Ŋe�X�̕������ɑ΂��āA1�s���\������Ă��܂��B
% PDE �c�[���{�b�N�X�ɂ́A2�̕W���I�ȎO�p�`�̑I����@ PDEADWORST �� 
% PDEADGSC ������܂��BPDEADWORST �́A�O�p�`�̐��x��\�킷�����l ERRF(�f
% �t�H���g:0.5)���z����O�p�`��I�����܂��BPDEADGSC �́A���΋��e�K�͂��g
% ���ĎO�p�`��I�����܂��B
%
% �ו����̕��@�́A'longest' �܂��� 'regular' �̂����ꂩ�ɂȂ�܂��B�ڍ�
% �́AREFINEMESH ���Q�Ƃ��Ă��������B
%
% �A�_�v�e�B�u�A���S���Y���́A����` PDE �����������Ƃ��ł��܂��B���
% �` PDE ���ɑ΂��ẮA'Nonlin' �p�����[�^�� 'on' �ɐݒ肵�Ȃ���΂Ȃ�
% �܂���B����`�̌덷�̋��e�͈� Toln �Ɣ���`�̏����l U0 �́A����`�\��
% �o�ɓn����܂��B�ڍׂ́APDENONLIN ���Q�Ƃ��Ă��������B
%
% �Q�l   ASSEMPDE, PDEBOUND, PDEGEOM, INITMESH, REFINEMESH, PDENONLIN



%       Copyright 1994-2001 The MathWorks, Inc.
