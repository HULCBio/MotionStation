% MENU   ���[�U���͂ɑ΂��đI�����j���[���쐬
% 
% CHOICE = MENU(HEADER, ITEM1, ITEM2, ... ) �́A������ HEADER �ƁA����
% �ɑ����ă��j���[�A�C�e�������� ITEM1�AITEM2�A... ITEMn ��\�����܂��B
% �I���������j���[�A�C�e�������A�X�J���l CHOICE �Ƃ��ďo�͂��܂��B���j���[
% �A�C�e�����ɐ����͂���܂���B
%
% CHOICE = MENU(HEADER, ITEMLIST) �́AITEMLIST ��������̃Z���z��̂Ƃ��A
% �L���ȃV���^�b�N�X�ł��B
%
% �قƂ�ǂ̃O���t�B�b�N�X�[���ŁAMENU �́A����figure���Ń{�^��������
% �悤�Ƀ��j���[�A�C�e����\�����܂��B���̏ꍇ�A�R�}���h�E�B���h�E����
% �ԍ��t����ꂽ���X�g�Ƃ��ė^�����܂�(���L�̗����Q��)�B
%
% �R�}���h�E�B���h�E�̗��:
% 
%    >> K = MENU('Choose a color','Red','Blue','Green')
% 
% �́A�X�N���[����ɂ��̂��̂�\�����܂��B
%
%   ----- Choose a color -----
%
%      1) Red
%      2) Blue
%      3) Green
%
%      Select a menu number:
%
% �v�����v�g�ɑΉ����ă��[�U�����͂������l�́AK�Ƃ��ďo�͂���܂�(���Ƃ��΁A
% K = 2�́A���[�U��Blue��I���������Ƃ��Ӗ����܂�)�B
% 
% �Q�l�FUICONTROL, UIMENU, GUIDE.


%   J.N. Little 4-21-87, revised 4-13-92 by LS, 2-18-97 by KGK.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:29 $
