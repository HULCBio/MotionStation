%WEB Web�u���E�U�ŃT�C�g�܂��̓t�@�C�����J��
% WEB �́A��̓��� web �u���E�U���J���܂��B�f�t�H���g�̓��� web �u���E�U�ɂ́A
% �W���� web �u���E�U�A�C�R�������c�[���o�[�ƁA�J�����g�̃A�h���X������
% �A�h���X�{�b�N�X������܂��B
%
% WEB URL �́A�w�肵��URL(Uniform Resourde Locator) ����� Web �u���E�U��
% �\�����܂��B1�܂��͕����̓��� web �u���E�U�����łɎ��s���Ă���ꍇ�A
% �ŋ߂̃A�N�e�B�u�u���E�U (�ł��ŋ߂Ƀt�H�[�J�X���ꂽ���ƂŌ��܂�܂�) ���A
% �Ďg�p����܂��BURL �� docroot �̉��ɂ���ꍇ�A�����I�Ƀw���v�u���E�U�� 
% �ɕ\������܂��B
%
% WEB URL -NEW �́A�V���������� web �u���E�U�E�B���h�E�Ɏw�肵�� URL ��
% �\�����܂��B
%
% WEB URL -NOTOOLBAR �́A���� web �u���E�U�ɁA�c�[���o�[ (�� address box) 
% ���Ȃ���ԂŁA�w�肵�� URL ��\�����܂��B
%
% WEB URL -NOADDRESSBOX �́A���� web �u���E�U�ɁAaddress box ���Ȃ�
%(�W�� web �u���E�U�A�C�R��������c�[���o�[�͂���)��ԂŁA�w�肵��
% URL ��\�����܂��B
%
% WEB URL -HELPBROWSER �́A�w���v�u���E�U�Ɏw�肵�� URL ��\�����܂��B
%
% STAT = WEB(...) -BROWSER �́AWEB �R�}���h�̃X�e�[�^�X��ϐ� STAT ��
% �o�͂��܂��BSTAT= 0 �́A����I���������Ƃ������܂��BSTAT = 1 �́A
% �u���E�U��������Ȃ��������Ƃ������܂��BSTAT = 2 �́A�u���E�U��
% �����������A�N���ł��Ȃ��������Ƃ������܂��B
%
% [STAT, BROWSER] = WEB �́A�ł��ŋ߃A�N�e�B�u�ɂȂ����u���E�U�̏�Ԃ�
% �n���h�����o�͂��܂��B
%
% [STAT, BROWSER, URL] = WEB �́A�ł��ŋ߃A�N�e�B�u�ɂȂ����u���E�U��
% ��Ԃƃn���h���A����сA�J�����g�ʒu�� URL ���o�͂��܂��B
%
% WEB URL -BROWSER �́ASystem Web �u���E�U���I�[�v�����āAURL (Uniform 
% Resource Locator) �Ŏw�肵�� Web �T�C�g��t�@�C�������[�h���܂��B
% URL�́A���[�U�̃u���E�U���T�|�[�g�ł���C�ӂ̌`���ł��B��ʂɁA���[�J��
% �t�@�C����C���^�[�l�b�g���Web�T�C�g���w�肷�邱�Ƃ��ł��܂��B UNIX (Mac 
% �͊܂܂Ȃ�) ��ł́A�g�p���� Web �u���E�U�́ADOCOPT M-�t�@�C���̒��Őݒ�
% ����Ă��܂��BWindows �� Macintosh ��ł́AWeb �u���E�U�̓I�y���[�e�B���O
% �V�X�e���Ō��肳��܂��B
%
% ���:
%      web file:///disk/dir1/dir2/foo.html
%         �́A�����u���E�U�Ƀt�@�C�� foo.html ���J���܂��B
%
%      web(['file:///' which('foo.html')]);
%         �́A�t�@�C����MATLAB�p�X��ɂ���� foo.html ���J���܂��B
%
%      web('text://<html>Hello World</html>');
%         �́A�����u���E�U���ɁAhtml formatted text ���J���܂��B
%
%      web('http://www.mathworks.com', '-new');
%         �́A�V���������u���E�U��The MathWorks Web�y�[�W���J���܂��B
%
%      web('http://www.mathworks.com', '-new', '-notoolbar');
%         �́A�V���������u���E�U�ɁA�c�[���o�[ �܂��� address box ���Ȃ���ԂŁA

%�@�@�@�@ The MathWorks Web page �����[�h���܂��B
%
%      web('file:///disk/helpfile.html', '-helpbrowser');
%         �́A�w���v�u���E�U�Ƀt�@�C�� helpfile.html ���J���܂��B
%
%      web('file:///disk/dir1/dir2/foo.html', '-browser');
%         �́A�V�X�e���u���E�U�� �t�@�C�� foo.html ���J���܂��B
%
%      web mailto:email_address
%         �́A�V�X�e���u���E�U���g���ēd�q���[���𑗐M���܂��B
%
% �Q�l DOC, DOCOPT.

%   Copyright 1984-2004 The MathWorks, Inc.
