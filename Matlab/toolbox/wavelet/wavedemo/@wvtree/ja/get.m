%GET WVTREE �I�u�W�F�N�g�t�B�[���h�̓��e���擾
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) �́AWVTREE �I�u�W�F�N�g T
%   �ɑ΂���A�w�肳�ꂽ�t�B�[���h�̓��e���擾���܂��B
%   �I�u�W�F�N�g�A�܂��͍\���̂̃t�B�[���h�ɑ΂��āA�T�u�t�B�[���h�̓��e%   ���擾�ł��܂� (DTREE/GET ���Q��)�B
%
%   [...] = GET(T) �́AT �̂��ׂẴt�B�[���h�̓��e���o�͂��܂��B
%
%   'FieldName' �őI���ł�����e�͈ȉ��̒ʂ�ł��B
%     'dummy'   : �g�p���܂���B
%     'wtree'   : wtree �̐e�I�u�W�F�N�g�ł��B
%
%   �܂��́AWTREE �̐e�I�u�W�F�N�g���̃t�B�[���h�͈ȉ��̒ʂ�ł��B
%     'dwtMode' : DWT �g�����[�h
%     'wavInfo' : �\���� (�E�F�[�u���b�g�̏��)
%        'wavName' - �E�F�[�u���b�g��
%        'Lo_D'    - ���𑤃��[�p�X�t�B���^
%        'Hi_D'    - ���𑤃n�C�p�X�t�B���^
%        'Lo_R'    - �č\�������[�p�X�t�B���^
%        'Hi_R'    - �č\�����n�C�p�X�t�B���^
%
%   'FieldName' �̂��̑��̗L���ȑI���ɂ��Ă̂��ڍׂȏ��Ɋւ��ẮA%    help dtree/get �ƃ^�C�v���Ă��������B
%
%   �Q�l : DTREE/READ, DTREE/SET, DTREE/WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.



%   Copyright 1995-2002 The MathWorks, Inc.
