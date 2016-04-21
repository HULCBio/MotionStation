% TREETEST   �c���[�ɑ΂���덷��
%
% COST = TREETEST(T,'resubstitution') �́A�Ēu���̎�@��p���āA�c���[
% T �̃R�X�g���v�Z���܂��BT �́ATREEFIT �֐��ɂ���č쐬���ꂽ����؂�
% ���B�c���[�̃R�X�g�́A�I�[�m�[�h�̐���m���Ɋe�m�[�h�̃R�X�g��������
% ���̂̂��ׂĂɓn���Ęa���Ƃ�܂��BT �����ޖ؂̏ꍇ�A�m�[�h�̃R�X�g�́A
% �m�[�h���̊ϑ��̌딻�ʂ̘a�ł��BT �͉�A�؂̏ꍇ�A�m�[�h�̃R�X�g�́A
% �m�[�h���̊ϑ��Ɋւ���덷�̓�敽�ςł��BCOST �́AT �ɑ΂���œK��
% �폜(pruning) ����̊e�T�u�c���[�ɑ΂���R�X�g�l�̃x�N�g���ł��B
% �Ēu���̃R�X�g�́A�I���W�i���c���[���쐬���邽�߂Ɏg����̂Ɠ���
% �W�{�Ɋ�Â��܂��B�]���āA����͐V�����f�[�^�Ƀc���[��K�p����ۂ�
% �N���蓾��R�X�g���ߏ��]�����܂��B
%
% COST = TREETEST(T,'test',X,Y) �́A����W�{�Ƃ��āA�\���q�̍s�� X ��
% ���� Y ���g�p���A���̕W�{�Ɍ���� T ��K�p���A����W�{�ɑ΂��Čv�Z
% ���ꂽ�R�X�g�l�̃x�N�g�� COST ���o�͂��܂��BX �� Y �́A�c���[ T ��
% ���߂邽�߂ɗp�����W�{�ł���w�K�W�{�Ɠ����ł����Ă͂����܂���B
%
% COST = TREETEST(T,'crossvalidate',X,Y) �́A�R�X�g�x�N�g���̌v�Z��
% 10��������������g�p���܂��BX �� Y �́A�c���[ T �ɋߎ����邽�߂Ɏg�p
% ���ꂽ�W�{�ł���w�K�W�{�łȂ���΂����܂���B�֐��́A�W�{����������
% �����傫���̃����_���ɑI�����ꂽ10�̕��W�{�ɕ������܂��B���ޖ؂ɂ�
% �ẮA���W�{���܂��A�����������䗦�ŃN���X�W�{�������܂��B�X�̕��W
% �{�ɂ��āATREETEST �́A�c��̃f�[�^�Ƀc���[���ߎ����A����𕛕W�{
% ��\�����邽�߂Ɏg�p���܂��B����́A���ׂĂ̕W�{�ɑ΂���R�X�g���v�Z
% ���邽�߂ɁA���ׂĂ̕��W�{����̏����W�ς��Ă����܂��B
%
% [COST,SECOST,NTNODES,BESTLEVEL] = TREETEST(...) �́A�e COST �l�̕W��
% �덷���܂�ł���x�N�g�� SECOST �ƁA�e�T�u�c���[�ɑ΂��ďI�[�m�[�h��
% �����܂�ł���x�N�g�� NTNODES �ƁA���肳�ꂽ�폜(pruning)�̍œK���x
% �����܂�ł���X�J���� BESTLEVEL ���o�͂��܂��BBESTLEVEL=0 �́A�폜
% ����Ȃ�����(���Ȃ킿�A���S�Ȏ�菜����Ă��Ȃ��c���[)���Ӗ����܂��B
% �œK���x���Ƃ́A�ŏ��R�X�g�̃T�u�c���[����1�W���덷�ȓ��ɂ���ł�
% �����ȃc���[���쐬������̂ł��B
%
% [...] = TREETEST(...,'PARAM1',val1,'PARAM2',val2,...) �́A�ȉ�����
% �I�������I�v�V�����p�����[�^ ��/�l �̑g�ݍ��킹���w�肵�܂��B:
%
%    'nsamples'   ��������̕W�{�̐� (�f�t�H���g 10)
%    'treesize'   �R�X�g���ŏ��R�X�g����1�W���덷�ȓ��ƂȂ�ł�������
%                 �c���[��I������'se'(�f�t�H���g) ���A(�Ēu���̃G���[
%                 �̌v�Z�ɑ΂��Ă͏d�v�łȂ�)�ŏ��̃R�X�g�c���[��I��
%                 ���� 'min' �̂ǂ��炩�B
%
% ���:  ���������p���āAFisher �� iris data �ɑ΂���œK�ȃc���[��
%        �������܂��B�����́A�e�c���[�̑傫���ɑ΂��Đ��肳�ꂽ�R�X�g
%        �������A�_�����A�ŏ�����1�W���덷�̓_�������Ă��܂��B�܂��A
%        �����`�̃}�[�J�[���A�_���̉��ɂ���ł��������c���[�ɂ����
%        �܂��B
%    % �傫���c���[�Ŏn�߂܂�
%    load fisheriris;
%    t = treefit(meas,species','splitmin',5);
%
%    % �ŏ��̃R�X�g�c���[���������܂��B
%    [c,s,n,best] = treetest(t,'cross',meas,species);
%    tmin = treeprune(t,'level',best);
%
%    % �ŏ��̃R�X�g�c���[��1�W���덷�ȓ��̍ł��������c���[���v���b�g���܂��B
%    [mincost,minloc] = min(c);
%    plot(n,c,'b-o', n(best+1),c(best+1),'bs',...
%         n,(mincost+s(minloc))*ones(size(n)),'k--');
%    xlabel('Tree size (number of terminal nodes)')
%    ylabel('Cost')
%
% �Q�l : TREEFIT, TREEDISP, TREEPRUNE, TREEVAL.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/01/20 22:44:22 $
