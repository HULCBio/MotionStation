% �f�[�^�^�C�v�ƍ\����
%
% �f�[�^�^�C�v (�N���X)
% double          - �{���x�ɕϊ�
% char            - �L�����N�^�z��i������j�̍쐬
% logical         - ���l��_���l�ɕϊ�
% cell            - �Z���z��̍쐬
% struct          - �\���̔z��̍쐬�܂��͕ϊ�
% single          - �P���x�ɕϊ�
% uint8           - �����Ȃ�8�r�b�g�����ɕϊ�
% uint16          - �����Ȃ�16�r�b�g�����ւ̕ϊ�
% uint32          - �����Ȃ�32�r�b�g�����ւ̕ϊ�
% uint64          - �����Ȃ�64�r�b�g�����ւ̕ϊ�
% int8            - �����t��8�r�b�g�����ւ̕ϊ�
% int16           - �����t��16�r�b�g�����ւ̕ϊ�
% int32           - �����t��32�r�b�g�����ւ̕ϊ�
% int64           - �����t��64�r�b�g�����ւ̕ϊ�
% inline          - INLINE�I�u�W�F�N�g�̍쐬
% function_handle - �֐��n���h���z��
% javaArray       - Java �z��̍쐬
% javaMethod      - Java ���\�b�h�̋N��
% javaObject      - Java �I�u�W�F�N�g�R���X�g���N�^�̋N��
%
% �N���X����֐�
% isnumeric       - ���l�z��ɑ΂��� True 
% isfloat         - �P���x����є{���x�̕��������_�z��ɑ΂��� True
% isinteger       - �����f�[�^�^�C�v�̔z��ɑ΂��� True
% islogical       - �_���z��ɑ΂��� True
% ischar          - �����z��ɑ΂��� True (������)
% 
% �������z��֐�
% cat         - �z��̌���
% ndims       - �z��̎�����
% ndgrid      - N�����֐����Ԃɑ΂���z��̍쐬
% permute     - �z��̎����̍Ĕz��
% ipermute    - �z��̎����̍Ĕz��̋t����
% shiftdim    - �����̃V�t�g
% squeeze     - 1�̎���(�V���O���g������)�̍폜
%
% �Z���z��֐�
% cell        - �Z���z��̍쐬
% cellfun     - �Z���z��������Ƃ���֐�
% celldisp    - �Z���z��̓��e��\��
% cellplot    - �Z���z��̍\�����O���t�B�J���ɕ\��
% cell2mat    - 1�̍s����ɍs��̃Z���z�������
% mat2cell    - �s��̃Z���z����̍s��𕪉�
% num2cell    - ���l�z����Z���z��ɕϊ�
% deal        - ���͂��o�͂֕��z
% cell2struct - �Z���z����\���̔z��ɕϊ�
% struct2cell - �\���̔z����Z���z��ɕϊ�
% iscell      - �Z���z��̌��o
%
% �\���̊֐�
% struct      - �\���̔z��̍쐬�܂��͕ϊ�
% fieldnames  - �\���̔z��̃t�B�[���h���̎擾
% getfield    - �\���̔z��̃t�B�[���h�̓��e�̎擾
% setfield    - �\���̔z��̃t�B�[���h�̐ݒ�
% rmfield     - �\���̔z��̃t�B�[���h�̍폜
% isfield     - �\���̔z����̃t�B�[���h�̌��o
% isstruct    - �\���̔z��̌��o
% orderfields - �\���̔z��̃t�B�[���h�̏��Ԃ̕��בւ�
%
% �֐��n���h���֐�
% @               - function_handle�̍쐬
% func2str        - function_handle �z��𕶎���ɕϊ�
% str2func        - ������� function_handle �z��ɕϊ�
% methods         - function_handle �Ɋ֘A�����֐��̃��X�g
%
% �I�u�W�F�N�g�w���v���O���~���O�֐�
% class           - �I�u�W�F�N�g�̍쐬�ƃI�u�W�F�N�g�N���X�̏o��
% struct          - �I�u�W�F�N�g���\���̔z��ɕϊ�
% methods         - �N���X�̃��\�b�h���ƃv���p�e�B���̃��X�g
% methodsview     - �N���X�̃��\�b�h���ƃv���p�e�B�̕\��
% isa             - �^����ꂽ�N���X�̃I�u�W�F�N�g�̌��o
% isjava          - Java�I�u�W�F�N�g�̌��o
% isobject        - MATLAB �I�u�W�F�N�g�̌��o
% inferiorto      - ���ʃN���X�̊֌W
% superiorto      - ��ʃN���X�̊֌W
% substruct       -  SUBSREF/SUBSASGN�ɑ΂���\���̈������쐬
%
% �I�[�o���[�h�\�ȉ��Z�q
% minus       - ���Z a-b�ɑ΂���I�[�o���[�h��@
% plus        - ���Z a+b�ɑ΂���I�[�o���[�h��@
% times       - ��Z a.*b�ɑ΂���I�[�o���[�h��@
% mtimes      - �s��̏�Z a*b�ɑ΂���I�[�o���[�h��@
% mldivide    - �s��̍����Z a\b�ɑ΂���I�[�o���[�h��@
% mrdivide    - �s��̉E���Z a/b�ɑ΂���I�[�o���[�h��@
% rdivide     - �z��̉E���Z a./b�ɑ΂���I�[�o���[�h��@
% ldivide     - �z��̍����Z a.\b�ɑ΂���I�[�o���[�h��@
% power       - �z��̃x�L�� a.^b�ɑ΂���I�[�o���[�h��@
% mpower      - �s��̃x�L�� a^b�ɑ΂���I�[�o���[�h��@
% uminus      - �P�����Z -a�ɑ΂���I�[�o���[�h��@
% uplus       - �P�����Z +a�ɑ΂���I�[�o���[�h��@
% horzcat     - �������� [a b]�ɑ΂���I�[�o���[�h��@
% vertcat     - �������� [a;b]�ɑ΂���I�[�o���[�h��@
% le          - ��r���Z a< = b�ɑ΂���I�[�o���[�h��@
% lt          - ��r���Z a<b�ɑ΂���I�[�o���[�h��@
% gt          - ��r���Z a>b�ɑ΂���I�[�o���[�h��@
% ge          - ��r���Z a> = b�ɑ΂���I�[�o���[�h��@
% eq          - ��r���Z a == b�ɑ΂���I�[�o���[�h��@
% ne          - ��r���Z a~ = b�ɑ΂���I�[�o���[�h��@
% not         - �_�����Z ~a�ɑ΂���I�[�o���[�h��@
% and         - �_�����Z a&b�ɑ΂���I�[�o���[�h��@
% or          - �_�����Z a|b�ɑ΂���I�[�o���[�h��@
% subsasgn    - a(i) = b�Aa{i} = b�Aa.field = b�ɑ΂���I�[�o���[�h��@
% subsref     - a(i)�Aa{i}�Aa.field�ɑ΂���I�[�o���[�h��@
% colon       - a:b�ɑ΂���I�[�o���[�h��@
% end         - a(end)�ɑ΂���I�[�o���[�h���\�b�h
% transpose   - �s��]�u a.'
% ctranspose  - ���f�]�u a'
% subsindex   - x(a)�ɑ΂���I�[�o���[�h��@
% loadobj     - .MAT�t�@�C������I�u�W�F�N�g��ǂݍ��ޏꍇ�̌Ăяo��
% saveobj     - .MAT�t�@�C���ɃI�u�W�F�N�g��ۑ�����ꍇ�̌Ăяo��


%   Copyright 1984-2002 The MathWorks, Inc.
