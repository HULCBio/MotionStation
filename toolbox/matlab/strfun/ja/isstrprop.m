%ISSTRPROP ������̗v�f���w�肵���J�e�S���ł��邩���m�F
% B = ISSTRPROP(S,C) �́AS�Ɠ����`��̘_���z���B�ɏo�͂��܂��B����́A
% S�̗v�f��������J�e�S��C�ł��邱�Ƃ��m�F���܂��BS�̃^�C�v�́A�Z���z��A
% �����A�܂��͔C�ӂ�MATLAB���l�^�C�v�ł��܂��܂���BS�̓Z���z��̏ꍇ�́A
% B��S�Ɠ����`��̃Z���z��ł��BS�̗v�f�̕��ނ́A�w�肵���J�e�S����Unicode
% ��`�ɏ]���čs���܂��B�܂�A���͔z����̗v�f�̐��l��Unicode�L�����N�^
% �J�e�S�����`����͈͂ɂ���ꍇ�́A���̗v�f�́A���̃J�e�S���ł���ƕ���
% ����܂��BUnicode�L�����N�^�R�[�h�̏W���́AASCII �L�����N�^�R�[�h���܂݂�
% �����AASCII�Z�b�g�͈̔͂����L��������J�o�[���܂��B�L�����N�^�̕��ނ́A
% MATLAB��locale�ݒ�ɂ��܂��B 
%
% ���͈���
%
% S �́Achar, int8, uint8, int16, uint16, int32, uint32, int64,
% uint64, double, �Z���z��̂����ꂩ�ł��B�Z���z��́A��L�̃^�C�v�̔z����܂�
% ���Ƃ��\�ł��B
%   
% �^�C�vdouble�̐��l�́AMATLAB��double-to-int�̕ϊ��@���ɂ���������int32��
% �ϊ�����܂��Bint32(inf)�����傫���^�C�vint64�����uint64�̐��l�́A
% int32(inf)�ɂȂ�܂��B 
%
% ����C�́A���̕�����łȂ���΂Ȃ�܂���:
% 'alpha'     : S���p���Ƃ��ĕ���
% 'alphanum'  : S���p�����Ƃ��ĕ���
% 'cntrl'     : S���R���g���[���L�����N�^, char(0:20)�Ƃ��ĕ���
% 'digit'     : S�𐔒l�Ƃ��ĕ���
% 'graphic'   : S���O���t�B�b�N�X�L�����N�^�Ƃ��ĕ��ށB�����́A
%             {unassigned, space, line separator, paragraph separator, control
%             characters, Unicode format control characters, private
%             user-defined characters, Unicode surrogate characters, Unicode
%             other characters}�łȂ��L�����N�^��\�킷���ׂĂ̒l�ł��B
% 'lower'     : S���������Ƃ��ĕ���
% 'print'     : S���O���t�B�b�N�X�L�����N�^�A�v���Xchar(32)�Ƃ��ĕ���             
% 'punct'     : S����Ǔ_�L�����N�^�Ƃ��ĕ���
% 'wspace'    : S���󔒃L�����N�^�Ƃ��ĕ���; ���͈̔͂́A�󔒂�ANSI C ��`
%             {' ','\t','\n','\r','\v','\f'}���܂݂܂��B
% 'upper'     : S��啶���Ƃ��ĕ���
% 'xdigit'    : S��L����16�i���Ƃ��ĕ���
%
%   ���
%
% B = isstrprop('abc123efg','alpha') �́AB  => [1 1 1 0 0 0 1 1 1]���o�͂��܂��B
% B = isstrprop('abc123efg','digit') �́AB  => [0 0 0 1 1 1 0 0 0]���o�͂��܂��B
% B = isstrprop('abc123efg','xdigit') �́AB => [1 1 1 1 1 1 1 1 0]���o�͂��܂��B
% B = isstrprop([97 98 99 49 50 51 101 102 103],'digit') �́A
%     B => [0 0 0 1 1 1 0 0 0]���o�͂��܂��B
% B = isstrprop(int8([97 98 99 49 50 51 101 102 103]),'digit') �́A
%     B => [0 0 0 1 1 1 0 0 0]���o�͂��܂��B
% B = isstrprop(['abc123efg';'abc123efg'],'digit') �́A
%     B => [0 0 0 1 1 1 0 0 0; 0 0 0 1 1 1 0 0 0]���o�͂��܂��B
% B = isstrprop({'abc123efg';'abc123efg'},'digit') �́A
%     B => {[0 0 0 1 1 1 0 0 0]; [0 0 0 1 1 1 0 0 0]}���o�͂��܂��B
% B = isstrprop(sprintf('abc\n'),'wspace') �́AB  => [0 0 0 1]���o�͂��܂��B
%
%   �Q�l: ISCHAR.






