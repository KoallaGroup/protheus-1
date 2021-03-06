#include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LP59001  � Autor � Tiago Augusto Gomes   � Data � 05.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � RDMAKE para localizacao da Conta Contabil correta a ser    ���
���          � debitada o Valor de ISSQN.                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ESPECIFICO PARA EPC                                        ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA  � MOTIVO DA ALTERACAO                              ���
�������������������������������������������������������������������������Ĵ��
���            �       �                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LP59001()

SetPrvt("CPREFIXO,CTITULO,CISSQN,CCODCLI,CLOJCLI,CCONTAISS,")

If AllTrim(SEF->EF_FORNECE) == "MUNIC"  // Checa o Fornecedor padr�o de ISSQN
	cPrefixo := SEF->EF_PREFIXO	        // Recebe o Prefixo do T�tulo de ISSQN
	cTitulo  := SEF->EF_TITULO	     	// Recebe o Numero do T�tulo de ISSQN
	dbSelectArea("SE1")
	dbSetOrder(1)
	If dbSeek(xFilial("SE1")+cPrefixo+cTitulo+" NF")
		cCodCli := SE1->E1_CLIENTE
		cLojCli := SE1->E1_LOJA
	    // Descobrir a Conta Cont�bil de ISS no Cadastro de Clientes
	    DbSelectArea("SA1")
	    DbSetOrder(1)
	    If DbSeek(xFilial("SA1")+cCodCli+cLojCli)
    		cContaISS := AllTrim(SA1->A1_CONTISS)
	    EndIf
	EndIf      
   Else
    cContaISS := "1" // Criado para que o Sistema nao tente retornar um variavel inexistente
Endif
Return(cContaISS) // Retorna a conta contabil que sera debitada.