% TREEPRUNE   �}����菜�����Ƃɂ��T�u�c���[�̗�̐���
%
% T2 = TREEPRUNE(T1,'level',LEVEL) �́ATREEFIT �֐��ɂ���č쐬���ꂽ
% ����� T1 �ƍ폜(pruning)���x�� LEVEL ������āA���̃��x���Ŏ}�����
% �����ꂽ����� T2 ���o�͂��܂��BLEVEL=0 �̒l�́A������菜����Ȃ���
% �Ƃ��Ӗ����܂��B�c���[�́A�ŏ��Ɏ�菜���}���A�G���[�̃R�X�g�̑�����
% �ŏ��ɗ}����悤�ɁA�œK�ȍ폜(pruning)�v������ƂɎ�菜����܂��B
%
% T2 = TREEPRUNE(T1,'nodes',NODES) �́A�c���[����� NODES �x�N�g������
% ���X�g���ꂽ�m�[�h����菜���܂��B�����̐e����菜����Ă��Ȃ��ꍇ�A
% NODES �Ƀ��X�g���ꂽ�ǂ�� T1 �}�̃m�[�h���AT2 ���̗t�̃m�[�h�ɂȂ�
% �܂��BTREEDISP �֐��́A�I�������C�ӂ̃m�[�h�ɑ΂��ăm�[�h�ԍ���\��
% ���邱�Ƃ��ł��܂��B
%
% T2 = TREEPRUNE(T1) �́AT1 ���牽����菜���Ă��Ȃ����S�Ȍ���؂ɍœK
% �ȍ폜(pruning)��������������� T2 ���o�͂��܂��B����́AT1 ������
% �c���[����폜���s���ē���ꂽ���̂ł���ꍇ�A�܂��́A�폜(pruning)
% �̐ݒ�� 'off' �ɂ��� TREEFIT �֐����g���č쐬���ꂽ�ꍇ�̂ݗL�p�ł��B
% �œK�ȍ폜���s��(pruning)�菇�ɉ����āA�c���[�𕡐����菜���ꍇ�A
% �ŏ��ɍœK�ȍ폜���s��(pruning)����쐬���邱�Ƃ͂����ʂ�����܂��B
%
% �}����菜�����Ƃ́A�������̎}�m�[�h��t�̃m�[�h�ɕς��āA�I���W�i��
% �̎}�̉��̗t�̃m�[�h���폜���邱�Ƃɂ��A�c���[���k�����鏈���ł��B
%
% ���:  �œK�ȍ폜(pruning)�菇�ɉ����āAFisher�� ires data �ɑ΂���
% ���S�ȃc���[��2�Ԗڂɑ傫�ȃc���[��\�����܂��B
%    load fisheriris;
%    t = treefit(meas,species,'splitmin',5);
%    treedisp(t);
%    t1 = treeprune(t,'level',1);
%    treedisp(t1);
%
% �Q�l : TREEFIT, TREETEST, TREEDISP, TREEVAL.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/03/26 14:57:28 $

