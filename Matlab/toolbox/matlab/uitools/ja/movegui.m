% MOVEGUI  GUI figure���X�N���[���̎w�肵�������Ɉړ�
%
% MOVEGUI(H, POSITION) �́A�n���h�� H �Ɋ֘A����figure���A�T�C�Y��ێ�
% �����܂܁A�X�N���[���̐ݒ肵�������Ɉړ����܂��B
%
% H �́Afigure�̃n���h���A�܂���figure�Ɋ֘A���邠��u�W�F�N�g�̂����ꂩ
% ��ݒ�ł��܂�(���Ƃ��΁Apushbutton uicontrol ���܂�figure���Apushbutton 
% �֐��n���h���̃R�[���o�b�N����ړ����邱�Ƃ��ł��܂�)�B
%
% ���� POSITION �́A���̂����ꂩ�̕�������̗p���邱�Ƃ��ł��܂��B
%     'north'     - �X�N���[���̒����̏㕔�̃G�b�W
%     'south'     - �X�N���[���̒����̉����̃G�b�W
%     'east'      - �X�N���[���̒����̉E�G�b�W
%     'west'      - �X�N���[���̒����̍��G�b�W
%     'northeast' - �X�N���[���̏㕔�̉E�[
%     'northwest' - �X�N���[���̏㕔�̍��[
%     'southeast' - �X�N���[���̉����̉E�[
%     'southwest' - �X�N���[���̉����̍��[
%     'center'    - �X�N���[���̒���
%     'onscreen'  - �J�����g�̈ʒu�ɍł��߂��X�N���[���̈ʒu
%
% ���� POSITION �́A2�v�f�x�N�g�� [H,V] �Őݒ肵�܂��B�����ŁA�����ɂ��
% H �́A�X�N���[���̍��[����A�܂��͉E�[�����figure�̃I�t�Z�b�g���w�肵�A
% V �́A�X�N���[���̏�A�܂��͉�����̃I�t�Z�b�g��ݒ肵�܂��B
% �P�ʂ́A�s�N�Z���ł��B
% 
%     H ( h >= 0) �́A���[����̃I�t�Z�b�g
%     H ( h < 0)  �́A�E�[����̃I�t�Z�b�g
%     V ( v >= 0) �́A������̃I�t�Z�b�g
%     V ( v < 0) �́A�ォ��̃I�t�Z�b�g
%
% MOVEGUI(POSITION) �́AGCBF �܂��� GCF ���w�肵���ʒu�Ɉړ����܂��B
%
% MOVEGUI(H) �́A�w�肵��figure��'onscreen' �Ɉړ����܂��B
%
% MOVEGUI �́AGCBF �܂��� GCF 'onscreen'���ړ����܂�(�ۑ�����figure
% �p�ɕ�����x�[�X��CreateFcn �R�[���o�b�N�Ƃ��ė��p�\�ŁA�ۑ���
% ���ʒu�Ɋւ�炸�A�ă��[�h�����Ƃ�onscreen�ɕ\��邱�Ƃ�ۏ؂��܂�)�B
%
% MOVEGUI(H, <event data>)
% MOVEGUI(H, <event data>, POSITION) �́A�֐��n���h���̃R�[���o�b�N�Ƃ���
% �g�p�����Ƃ��A�w�肵��figure���f�t�H���g�̈ʒu�Ɉړ����邩�A�܂��́A
% �w�肵���ʒu�Ɉړ����܂��B���̏ꍇ�A�����I�ɓn���ꂽ�C�x���g�f�[�^
% �\���𖳎����܂��B
%
% ���F
% ���̗��́A�ۑ����ꂽ GUI ���X�N���[���T�C�Y�ƕ���\�̈Ⴂ��A�ۑ�
% �������̂ƁA�ă��[�h�����Ƃ��̃}�V���̈Ⴂ�Ɋւ�炸�A�ۑ����ꂽGUI���A
% �ă��[�h���ꂽ�Ƃ���onscreen �ɕ\��邱�Ƃ�ۏ؂�����@�Ƃ��ėL���ł���
% ���Ƃ������܂��B�X�N���[���� CreateFcn �R�[���o�b�N�Ƃ���MOVEGUI ������
% ���ĂāA�X�N���[���Ƃ͕ʂ�figure���쐬���܂��B�����āAfigure��ۑ�����
% �ă��[�h���܂��B
%
%    	f=figure('position', [10000, 10000, 400, 300]);
%    	set(f, 'CreateFcn', 'movegui')
%    	hgsave(f, 'onscreenfig')
%    	close(f)
%    	f2 = hgload('onscreenfig')
%
% �ȉ��́A�ǉ����������A�����Ȃ��Ɋւ�炸�A������Ɗ֐��n���h����
% �g����CreateFcn �Ƃ���MOVEGUI ��ݒ肷���X�̕��@�ŁA��X�̋�����
% ������ł��B
%
%    	set(gcf, 'CreateFcn', 'movegui center')
%    	set(gcf, 'CreateFcn', @movegui)
%    	set(gcf, 'CreateFcn', {@movegui, 'northeast'})
%    	set(gcf, 'CreateFcn', {@movegui, [-100 -50]})
%
% �Q�l �F OPENFIG, GUIHANDLES, GUIDATA, GUIDE.


%   Damian T. Packer 2-5-2000
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 02:08:34 $
