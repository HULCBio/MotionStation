% DOS   DOS�R�}���h�̎��s�ƌ��ʂ̏o��
% 
% [status�Aresult] = DOS('command'�A'-echo')�́AWindows�V�X�e���ɑ΂��āA
% �ݒ肵���R�}���h�̎��s�̂��߂ɃV�F�����Ăяo���܂��B�R���\�[��(DOS)�v
% ���O������Windows�v���O�����̗��������s�ł��܂����A�v���O�����̃^�C�v
% �̈Ⴂ�ɂ��A�V���^�b�N�X���قȂ錋�ʂ��o�͂��܂��B�R���\�[���v���O��
% ���́Astdout�������A�o�͂͌��ʕϐ��ɏo�͂���܂��B�����́A���L�̗�O
% �������āA��ɃA�C�R�������ꂽDOS�E�B���h�E�A�܂��̓R�}���h�v�����v�g�E�B
% ���h�E�Ŏ��s����܂��B�R���\�[���v���O�����́A�o�b�N�O���E���h�ł͎��s��
% ��܂���B�܂��AMATLAB�́A���s���ĊJ����O�ɁAstdout pipe���폜�����
% �̂���ɑ҂��܂��BWindows�v���O������stdout�������Ȃ��̂ŁA�o�b�N
% �O���E���h�Ŏ��s�ł��܂��B
% 
% DOS�R�}���h�́A�I�v�V������2�Ԗڂ̈��� '-echo'�������܂��B����́A�ϐ�
% �Ɋ��蓖�Ă��Ă��Ă��A�o�͂������I�ɃR�}���h�E�B���h�E�ɏo�͂��܂��B
%
% �����ɑ����L�����N�^�́A���ʂȈӖ��������܂��B
% '&' - �R���\�[���v���O�����ɑ΂��āA�R���\�[�����J���܂��B���̃L�����N
%       �^���ȗ�����ƁA�R���\�[���v���O�������A�C�R�������Ď��s���܂��B
% 
%        Windows�v���O�����ɑ΂��āA���̃L�����N�^��ǉ�����ƁA�o�b�N�O
%        ���E���h�ŃA�v���P�[�V���������s���܂��BMATLAB�͏����𑱂��܂��B
%
% ���� : Windows 95, Windows 98, Windows ME�ł́A�g�ݍ��݂�DOS�R�}���h
% (��F"dir" ����� "echo") ��DOS�̃o�b�`�X�N���v�g(�t�@�C�����̖�����
% ".bat"�ł���X�N���v�g)�́A��ɃX�e�[�^�X0���o�͂��܂��B
% Windows�A�v���P�[�V������DOS�R���\�[���A�v���P�[�V�����݂̂��A������
% �I�y���[�e�B���O�V�X�e����Ŕ�[���X�e�[�^�X�R�[�h���o�͂��܂��B
%
% ���:
%
%     [s, w] = dos('dir')
%
% �́A�f�B���N�g�������X�g���As = 0�ƁA���X�g���܂ޕ������w�ɏo�͂��܂��B
% 
%     dos('edit &')
%
% �́ADOS�E�B���h�E��DOS 5.0�G�f�B�^���J���܂��B
%
%     dos('notepad file.m &')
%
% �́Anotepad�G�f�B�^���J���A������MATLAB�ɃR���g���[����߂��܂��B
%
%       [s, w] = dos('net xxx')
%
% �́A"xxx"��net.exe�̗L���ȃI�v�V�����łȂ����߁As�ɔ�[���̒l���o�͂��A
% w�ɃG���[���b�Z�[�W���o�͂��܂��B
%
%     [s, w] = dos('dir'�A'-echo');
% 
% �́A���s���ꂽ'dir'�R�}���h�̌��ʂ�w�Ɋ��蓖�ĂāA������R�}���h
% �E�B���h�E�ɃG�R�[���܂��B
% 
% �Q�l�F SYSTEM, PUNCT�̉��ł� ! (���Q��)


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:01 $
%   Built-in function.

