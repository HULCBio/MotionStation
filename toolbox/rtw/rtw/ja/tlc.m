% TLC   Target Language Compiler
%
%     tlc [options] main-file
%
% Target Language Compiler�́Amodel.rtw�t�@�C������C�R�[�h�𐶐����邽��
% �� Real Time Workshop�ɂ���ėp�����܂��B
%
% RTW��build�X�N���v�g�́ATarget language compiler�������I�ɌĂяo���āA
% ���̕ϊ����s���܂��B���[�U�́A��ʂɂ���𒼐ڌĂяo���K�v�͂���܂���B
% �ڍׂ́ATarget Language Compiler�̃h�L�������g���Q�Ƃ��Ă��������B
%
%
% �I�v�V����:
%
%   -r <name>         �p������RTW�t�@�C����<name>�ł��邱�Ƃ��w��B
%
%   -v[<number>]      ���x�����ȗ����ꂽ�ꍇ�Averbose level (1)���w��B
%
%   -I<path>          ���[�J���C���N���[�h�t�@�C���ւ̃p�X���w��BTLC�́A
%                     �w�肳�ꂽ���ɂ��̃p�X���T�[�`���܂��B
%
%   -m[<number>|a]    .tlc�t�@�C���̕ϊ����I������O�ɁATLC�����|�[�g��
%                     ��G���[�̍ő吔(�f�t�H���g��5)���w��B
%
%   -O<path>          �o�̓t�@�C����u���p�X���w��B�f�t�H���g�ł́A�S��
%                     ��TLC �o�͂́A���̃f�B���N�g���ɍ쐬����܂��B
%
%   -d[g|n|o]         TLC�̃f�o�b�O���[�h���Ăяo���܂��B���̃��[�h�ł́A
%                     TLC�̓R���p�C�����Ƀq�b�g�������C���ƃq�b�g���Ȃ�
%                     ���C�����������O�t�@�C���𐶐����܂��B
%
%   -a<ident>=<expression>
%                     ���̃I�v�V�������g���āATLC�v���O�����̋�����ύX
%                     ���邽�߂ɗp����p�����[�^���w�肵�܂��B���̃I�v�V
%                     �����́A�p�����[�^�̃C�����C����t�@�C���T�C�Y�̐�
%                     ������ݒ肷�邽�߂�RTW�ɂ���ėp�����܂��B
%
% ���
% mymodel.rtw�����[�h���Averbose���[�h�ŁA��{�I�ȃ��A���^�C��TLC�v���O
% ���������s���܂��B
%
%	tlc -r mymodel.rtw -v grt.tlc
%
% �Q�l�F RTWGEN, RTW, MAKE_RTW, RTW_C, TLC_C, SIMULINK

%	Copyright 1994-2001 The MathWorks, Inc.
