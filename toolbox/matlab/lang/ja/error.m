%ERROR  ���b�Z�[�W�̕\���Ɗ֐��̒��~
% ERROR('MSGID', 'MESSAGE') �́A������ MESSAGE �ɃG���[���b�b�Z�[�W��\�����A
% �G���[�𔲂��āA�J�����g�Ɏ��s���Ă���M-�t�@�C������L�[�{�[�h�֐����
% �o�͂��܂��BMSGID �́A�G���[����ӂɎ��ʂ��邱�Ƃ��ł��郁�b�Z�[�W���ʎq
% �ł��B���b�Z�[�W���ʎq�́A<component>[:<component>]:<mnemonic> �̌`����
% ������ŁA<component> �� <mnemonic> �́A�p����������ł��B
% ���b�Z�[�W���ʎq�̗�́A'myToolbox:myFunction:fileNotFound' �ł��B
% ���������G���[�̎��ʎq�́A �֐� LASTERROR �ɂ���Ď擾���邱�Ƃ��ł��܂� 
% (���Ƃ��΁ACATCH �u���b�N���ŁA�ǂ̎�ނ̃G���[�����������������肵�܂�)�B
% MESSAGE �́A\t or \n �Ȃǂ̃G�X�P�[�v�V�[�N�G���X���܂ޕ�����ł��BERROR �́A
% �����̗���A�^�u�� newline �Ȃǂ̓K���ȃe�L�X�g�L�����N�^�ɕϊ����܂��B
%
% ERROR('MSGID', 'MESSAGE', A, ...) �́A���������G���[���b�Z�[�W��\�����A
% M-�t�@�C���𔲂��܂��B�G�X�P�[�v�V�[�N�G���X�ɉ����A������ MESSAGE �́A
% �֐� SPRINTF �ɂ��T�|�[�g�����AC ����̕ϊ��q (���Ƃ��΁A%s �܂��� %d) 
% ���܂݂܂��B�ǉ��̈��� A, ... �́A�����̎w��q�ɑ�������l��񋟂��܂��B
% �����̈����́A������A�܂��́A�X�J���[�̐��l�������Ƃ��ł��܂��B�L����
% �ϊ��q�Ɋւ�����́AHELP SPRINTF���Q�Ƃ��Ă��������B
%
% ERROR('MESSAGE', A, ...) �́A���������G���[���b�Z�[�W��\�����A
% M-�t�@�C���𔲂��܂��B������ MESSAGE �́A�֐� SPRINTF �ɂ��T�|�[�g
% �����A C ����̕ϊ��q (���Ƃ��΁A%s �܂��� %d) ���܂݂܂��BMSGID 
% �������Ȃ����߁A�G���[�ɑ΂��郁�b�Z�[�W���ʎq�́A�f�t�H���g�͋󕶎���
% �ɂȂ�܂��B
%
% ERROR('MESSAGE') �́A�����Ȃ��̃G���[���b�Z�[�W��\�����AM-�t�@�C����
% �����܂��B������  MESSAGE �Ɋ܂܂��G�X�P�[�v�V�[�N�G���X�A�܂��́A
% �ϊ��q�́A������\�킷�e�L�X�g�ɕϊ�����܂���BMSGID �������Ȃ����߁A
% �G���[�ɑ΂��郁�b�Z�[�W���ʎq�́A�f�t�H���g�͋󕶎���ɂȂ�܂��B
% ����ȏꍇ�Ƃ��āAMESSAGE ���󕶎���̏ꍇ�́A�A�N�V�����͉����s��ꂸ�A
% ERROR ��M-�t�@�C�����I�������ɏo�͂���܂��B
%
% ����: ���b�Z�[�W���ʎq���g�p���A�����Ȃ��̃��b�Z�[�W��\�����邽�߂ɂ́A
% �����g�p���Ă��������B
%
%       ERROR('MSGID', '%s', 'MESSAGE')
%
% ERROR(MSGSTRUCT) �́AMSGSTRUCT ���t�B�[���h 'message' ����� 'identifier' 
% �����X�J���[�\���̂Ƃ��āA���̂悤�ɓ��삵�܂��B
%
%       ERROR(MSGSTRUCT.identifier, '%s', MSGSTRUCT.message);
%
% (����: ����́A���b�Z�[�W�t�B�[�h�������Ȃ��ŕ\������邱�Ƃ��Ӗ����܂�)�B
% ����ȏꍇ�Ƃ��āAMSGSTRUCT ����̍\���̂̏ꍇ�A �A�N�V�����Ȃ���
% M-�t�@�C�����甲�����ɁAERROR ���o�͂��܂��B
%
% �Q�l RETHROW, LASTERROR, LASTERR, SPRINTF, TRY, CATCH, DBSTOP, ERRORDLG,
%      WARNING, DISP.

%   Copyright 1984-2002 The MathWorks, Inc. 
