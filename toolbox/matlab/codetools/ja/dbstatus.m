%DBSTATUS ���ׂẴu���[�N�|�C���g�̃��X�g
% DBSTATUS �́AERROR, CAUGHT ERROR, WARNING, NANINF ���܂ރf�o�b�K��
% �m���Ă��邷�ׂẴu���[�N�|�C���g�̃��X�g��\�����܂��B
%
%
% DBSTATUS MFILE�́A�w�肳�ꂽM-�t�@�C�����Őݒ肳�ꂽ�u���[�N�|�C���g��
% �\�����܂��BMFILE�́Am-�t�@�C���֐����A�܂��́AMATLABPATH�̑��Ε����p
% �X���łȂ���΂Ȃ�܂���(PARTIALPATH���Q��)�B  
%
%   S = DBSTATUS(...) �́A�u���[�N�|�C���g�����A���̍��ڂ���Ȃ�M�s1��
% �̍\���̂ɏo�͂��܂��B
%     name - �֐���
%     line - �u���[�N�|�C���g�̍s�ԍ�����Ȃ�x�N�g��
%     expression -- 'line' �t�B�[���h�̃��C���ɑ�������u���[�N�|�C���g
%                    conditional expression ������̃Z���x�N�g��
%     cond -- �����̕����� ('error', 'caught error', 'warning', �܂��� 
%             'naninf').
%     identifier -- cond �� 'error', 'caught error', �܂��� 'warning' 
%     �̂����ꂩ�ł���ꍇ�A����� cond state ���ݒ肳���AMATLAB 
%     Message Identifier ������̃Z���x�N�g���ł��B
%
% �Q�l DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%      DBQUIT, ERROR, PARTIALPATH, WARNING.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc. 
