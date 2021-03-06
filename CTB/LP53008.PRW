#include "rwmake.ch"
// NAO ESTA SENDO UTILIZADO MAIS
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LANPADDT � Autor � Tiago Augusto Gomes   � Data � 29.06.01 ���
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

User Function LP53008()

SetPrvt("CPREFIXO,CTITULO,CISSQN,CCODCLI,CLOJCLI,CCONTAISS,")

If AllTrim(SE2->E2_NATUREZ) == "11905"
	cPrefixo := SE2->E2_PREFIXO	// Recebe o Prefixo do T�tulo de ISSQN
	cTitulo  := SE2->E2_NUM		// Recebe o Numero do T�tulo de ISSQN
	cISSQN   := SE2->E2_VALOR 	// Recebe o Valor do T�tulo de ISSQN
	MsgStop("TA AQUI")
	dbSelectArea("SE1")
	dbSetOrder(1)
	If dbSeek(xFilial("SE1")+cPrefixo+cTitulo+" NF")
		If SE1->E1_ISS == cISSQN
		   cCodCli := SE1->E1_CLIENTE
		   cLojCli := SE1->E1_LOJA
	       // Descobrir a Conta Cont�bil de ISS no Cadastro de Clientes
	       DbSelectArea("SA1")
	       DbSetOrder(1)
	       If DbSeek(xFilial("SA1")+cCodCli+cLojCli)
    	   		cContaISS := AllTrim(SA1->A1_CONTISS)
	       EndIf
          Else
           cContaISS := "1" // Criado para que o Sistema nao tente retornar um variavel inexistente
	    EndIf
	   Else
    	cContaISS := "1" // Criado para que o Sistema nao tente retornar um variavel inexistente
	EndIf      
   Else
    cContaISS := "1" // Criado para que o Sistema nao tente retornar um variavel inexistente
Endif
Return(cContaISS) // Retorna a conta contabil que sera debitada.