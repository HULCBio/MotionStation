% RETHROW  �G���[�̍Ĕ��s
%
% RETHROW(ERR) �́A�ϐ� ERR �Ɋi�[���ꂽ�G���[���Ĕ��s���܂��B���ݎ��s
% ���Ă��� M-�t�@�C�����I�����A���䂪�L�[�{�[�h(�܂��́A�C�ӂɈ͂܂��
% ���� CATCH �u���b�N)�ɕԂ���܂��BERR �́A���Ȃ��Ƃ��ȉ���2�̃t�B�[
% ���h���܂ލ\���̂łȂ���΂Ȃ�܂���B
%
%       message    : �G���[���b�Z�[�W�̃e�L�X�g
%       identifier : �G���[���b�Z�[�W�̃��b�Z�[�W���ʎq
%
% (�G���[���b�Z�[�W���ʎq�ɂ��Ă̑����̏��ɂ��ẮA ERROR �̃w��
% �v���Q�Ƃ��Ă�������)
% �Ō�̃G���[���s�ɑ΂���L���� ERR �\���̂��擾����֗��ȕ��@�́A
% LASTERROR �֐��ɂ����̂ł��B
%
% RETHROW �́A�ʏ�Acatch �֘A�̑���̎��s��� CATCH �u���b�N�����
% �G���[���Ĕ��s���邽�߂ɁATRY-CATCH �X�e�[�g�����g�Ƒg�ݍ��킹�ė��p
% ���܂��B�Ⴆ�Έȉ��̂悤�Ɏ��s���܂�:
%
%       try
%           do_something
%       catch
%           do_cleanup
%           rethrow(lasterror)
%       end
%
% �Q�l:  ERROR, LASTERROR, LASTERR, TRY, CATCH, DBSTOP.

    
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:59:27 $
%   Built-in function.
