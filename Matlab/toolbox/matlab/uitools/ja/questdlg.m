% QUESTDLG   ����_�C�A���O�{�b�N�X
% 
% ButtonName = QUESTDLG(Question) �́A�Z���z��܂��͕�����(�x�N�g���܂���
% �s��)Question���A�K�؂ȃT�C�Y�̃E�C���h�E�ɍ����悤�ɁA�����I�ɉ��s
% �����_�C�A���O�{�b�N�X���쐬���܂��B�N���b�N�����{�^�����́A
% ButtonName �ɏo�͂���܂��Bfigure�̃^�C�g���́A2�ڂ̕����������
% �t�������Ďw��ł��܂��B����͒ʏ�̕�����Ƃ��ĉ��߂���܂��B  
%
% QUESTDLG �́AUIWAIT ���g���āA���[�U����������܂Ŏ��s���~���邱�Ƃ�
% �ł��܂��B
% 
% QUESTDLG �ɑ΂���f�t�H���g�̃{�^�����́A'Yes','No' 'Cancel' �ł��B
% ��L�̌Ăяo���V���^�b�N�X�ɑ΂���f�t�H���g�̓����́A'Yes' �ł��B
% ����́A�f�t�H���g��Button���w�肷��3�ڂ̈�����t�������āA�ύX
% �ł��܂��B���Ƃ��΁AButtonName = questdlg(Question,Title,'No') �̂悤��
% ���܂��B
%
% �֐��R�[���ւ̒ǉ��̈����Ƃ��āA�{�^��������̖��O(�P���܂��͕���)��
% ���͂��邱�ƂŁA�ő�3�̃J�X�^���{�^�������w��ł��܂��B�J�X�^����
% ButtonName �����͂����ƁA�f�t�H���g�� ButtonName �́A�ǉ��̈���
% DEFAULT ��t�������Ďw�肵�Ȃ���΂Ȃ�܂���B���Ƃ��΁A 
%
% ButtonName = questdlg(Question,Title,Btn1,Btn2,DEFAULT);
%
% �ŁA�����ŁADEFAULT = Btn1 �ł��B����́A�f�t�H���g�̓����Ƃ��� Btn1
% ���o�͂��܂��BDEFAULT �����񂪁A�{�^���̕����񖼂Ɉ�v���Ȃ��ꍇ�A
% ���[�j���O���b�Z�[�W���\������܂��B
%
% ������ Question ��TeX�̉��߂��g���ɂ́A�f�[�^�\���̂����̂悤��
% �Ō�̈����Ŏw�肵�Ȃ���΂Ȃ�܂���B
%
%     ButtonName = questdlg(Question,Title,Btn1,Btn2,OPTIONS);
% 
% OPTIONS�\���̂́ADefault �� Interpreter �̃����o�[��K�v�Ƃ��܂��B
% Interpreter�́A'none' �܂��� 'tex' �ŁADefault �͗p������f�t�H���g
% �̃{�^�����ł��B
%
% �_�C�A���O���A�L���ȑI���������ɕ���ꂽ�ꍇ�A���ʂ̒l�͋�ɂȂ�܂��B
%
% ���:
% 
%  ButtonName=questdlg('What is your wish?', ...
%                      'Genie Question', ...
%                      'Food','Clothing','Money','Money');
%
%  
%  switch ButtonName,
%    case 'Food', 
%     disp('Food is delivered');
%    case 'Clothing',
%     disp('The Emperor''s  new clothes have arrived.')
%     case 'Money',
%      disp('A ton of money falls out the sky.');
%  end % switch
%
% �Q�l�F TEXTWRAP, INPUTDLG.


%  Author: L. Dean
%  Copyright 1984-2002 The MathWorks, Inc.
