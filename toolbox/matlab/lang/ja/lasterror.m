% LASTERROR   �Ō�̃G���[���b�Z�[�W�Ɗ֘A������
%
% LASTERROR �́A���̃G���[�֘A���̂悤��MATLAB�ɂ���ė^������Ō�
% �̃G���[���b�Z�[�W���܂񂾍\���̂��o�͂��܂��BLASTERROR �\���̂́A
% �����Ȃ��Ƃ��ȉ��̃t�B�[���h���܂ނ��Ƃ��ۏ؂���܂��B
%
%       message    : �G���[���b�Z�[�W�̃e�L�X�g
%       identifier : �G���[���b�Z�[�W�̃��b�Z�[�W���ʎq
%   
% LASTERROR(ERR) �́A�Ō�̃G���[�Ƃ��� ERR ���Ɋi�[���ꂽ�����o��
% ���邽�߂ɁALASTERROR �֐���ݒ肵�܂��BERR �ɑ΂��邽���ЂƂ̐���
% �́A�\���̂łȂ���΂Ȃ�Ȃ����Ƃł��B��L�̃��X�g���Ɍ���� ERR ��
% �t�B�[���h���ŁA�����Ă���t�B�[���h�ɑ΂��ẮA�f�t�H���g���K�؂�
% �g��ꂽ���̂Ƃ��Ďg�p����܂��B(�Ⴆ�΁AERR �� 'identifier' 
% �t�B�[���h�������Ȃ��ꍇ�A��̕����񂪑���Ɏg���܂�)
%
% LASTERROR �́A�ʏ�ATRY-CATCH �X�e�[�g�����g���� RETHROW �֐��Ƒg��
% ���킹�Ďg���܂��B�Ⴆ��:
%
%       try
%           do_something
%       catch
%           do_cleanup
%           rethrow(lasterror)
%       end
%
% �����A�N���[���A�b�v�̑��삪���ۂɋN�������G���[���e�Ɉˑ�����ꍇ�A
% do_cleanup �� LASTERROR �^�C�v�̓��͂�C�ӂɎ擾���邱�Ƃɒ��ӂ���
% ���������B
%
% �Q��:  ERROR, RETHROW, TRY, CATCH, LASTERR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $ $Date: 2004/04/28 01:59:12 $
