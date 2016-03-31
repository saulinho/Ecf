*-- Declarar DLLs
PROCEDURE fpDeclara

	DO CASE
		
		CASE gcImpressora = "bematech"
		
			*-- abre o dia
			DECLARE INTEGER Bematech_FI_AberturaDoDia IN BemaFI32.DLL STRING, STRING
							
			*** Status impressora
			DECLARE INTEGER Bematech_FI_VerificaEstadoImpressora IN BemaFI32.DLL INTEGER @n_ack, INTEGER @n_st1, INTEGER @n_st2
			
			*-- programar aliquota
			declARE INTEGER Bematech_FI_ProgramaAliquota IN BemaFI32.DLL STRING, INTEGER
			
			*-- abrir cupom fiscal
			DECLARE INTEGER Bematech_FI_AbreCupom IN BemaFI32.DLL STRING @CNPJ_CPF
			
			*-- abrir cupom fiscal com cliente e endereço
			DECLARE INTEGER Bematech_FI_AbreCupomMFD IN BemaFI32.DLL STRING @CNPJ_CPF, string @nome, string @endereco
			
			*-- vende item
			DECLARE INTEGER Bematech_FI_VendeItem IN BemaFI32.DLL STRING, STRING, STRING, STRING, STRING , short, STRING, STRING ,STRING
			
			*-- fechar cupom fiscal
			DECLARE INTEGER Bematech_FI_FechaCupom IN BemaFI32.DLL STRING , STRING, STRING, STRING, STRING
			
			*-- cancela cupom fiscal
			DECLARE INTEGER Bematech_FI_CancelaCupom IN BemaFI32.DLL
			
			*-- cancela item
			DECLARE INTEGER Bematech_FI_CancelaItemGenerico IN BemaFI32.DLL STRING
			
			*-- fechar cupom
			DECLARE INTEGER Bematech_FI_FechaCupom IN BemaFI32.DLL STRING , STRING, STRING, STRING, STRING
				
		CASE gcImpressora = "epson"
		
			*** Status impressora
			DECLARE integer EPSON_Obter_Estado_ImpressoraEX IN InterfaceEpson.dll String @szEstadoImpressora, String @szEstadoFiscal, String @szRetornoComando, String @szMsgErro						
		
		CASE gcImpressora = "sweda"
		
			** abre o dia
			DECLARE INTEGER ECF_AberturaDoDia IN CONVECF.DLL STRING, STRING
					
			*** status impressora
			Declare integer ECF_VerificaEstadoImpressoraMFD IN CONVECF.DLL Integer @Ack, Integer @St1, Integer @St2, Integer @St3
			
			*** abrir cupom fiscal
			DECLARE INTEGER ECF_AbreCupom IN CONVECF.DLL STRING @CNPJ_CPF
			
			*** abrir cupom fiscal com cliente e endereço
			DECLARE INTEGER ECF_AbreCupomMFD IN CONVECF.DLL STRING @CNPJ_CPF, string @nome, string @endereco
			
			*** vende item
			DECLARE INTEGER ECF_VendeItem IN CONVECF.DLL STRING, STRING, STRING, STRING, STRING , short, STRING, STRING ,STRING 
			
			*** programar aliquota
			DECLARE INTEGER ECF_ProgramaAliquota IN CONVECF.DLL STRING, INTEGER
			
			** fechar cupom fiscal
			DECLARE INTEGER ECF_FechaCupom IN CONVECF.DLL STRING , STRING, STRING, STRING, STRING 
			
			*** status cupom fiscal
			Declare integer ECF_StatusCupomFiscal in CONVECF.DLL String @cupa
			
			*-- cancela cupom fiscal
			DECLARE INTEGER ECF_CancelaCupom IN CONVECF.DLL
			
			*-- cancela item
			DECLARE INTEGER ECF_CancelaItemGenerico IN CONVECF.DLL STRING 
		
		CASE gcImpressora = "teste"
		
		OTHERWISE
		
	ENDCASE	
	
ENDPROC

*-- Retorno das funções
FUNCTION fpRetorno
	LPARAMETERS tnRet

	IF tnRet = 1
		RETURN .T.
	ELSE
		WAIT CLEAR
		
		DO CASE
			CASE tnRet = 0
				MESSAGEBOX("Erro de comunicação.",16,PROPER(PROGRAM(3)))

			CASE tnRet = -2
				MESSAGEBOX("Parâmetro inválido na função.",16,PROPER(PROGRAM(3)))

			CASE tnRet = -3
				MESSAGEBOX("Alíquota não programada.",16,PROPER(PROGRAM(3)))

			CASE tnRet = -4
				MESSAGEBOX("O arquivo de inicialização BemaFI32.ini não foi encontrado no diretório de sistema do Windows.",16,PROPER(PROGRAM(3)))

			CASE tnRet = -5
				MESSAGEBOX("Erro ao abrir a porta de comunicação.",16,PROPER(PROGRAM(3)))

			CASE tnRet = -27
				MESSAGEBOX("Status da impressora diferente de 6,0,0 (ACK, ST1 e ST2).",16,PROPER(PROGRAM(3)))
		ENDCASE

		RETURN .F.
	ENDIF
ENDFUNC

*-- Status da impressora
PROCEDURE fpStatusImpressora

	PARAMETERS tnAck as Integer, tnSt1 as Integer, tnSt2 as Integer, tnSt3 as Integer
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_VerificaEstadoImpressora(@tnAck, @tnSt1, @tnSt2)
			fpRetorno(lnRetorno)
			
		CASE gcImpressora = "epson"
			LOCAL lcEstadoImpressora as String, lcEstadoFiscalAs as String, lcRetornoComando as string , lcMsgErro as String
			lcEstadoImpressora = SPACE(17)
			lcEstadoFiscalAs = SPACE(17)
			lcRetornoComando = SPACE(5)
			lcMsgErro = SPACE(101)
			RETURN EPSON_Obter_Estado_ImpressoraEX(@lcEstadoImpressora, @lcEstadoFiscalAs, @lcRetornoComando, @lcMsgErro)

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_VerificaEstadoImpressoraMFD(@tnAck, @tnSt1, @tnSt2, @tnSt3)
			fpRetorno(lnRetorno)
			
		OTHERWISE

	ENDCASE
	
	RETURN lnRetorno
	
ENDPROC

*-- abre o dia
PROCEDURE fpAbreDia

	PARAMETERS tcValor, tcFormaPag
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_AberturaDoDia(tcValor, tcFormaPag)
			
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_AberturaDoDia(tcValor, tcFormaPag)			
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno	
	
ENDPROC

*-- abrir cupom fiscal
PROCEDURE fpAbreCupom

	PARAMETERS tcCnpjCpf
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_AbreCupom(tcCnpjCpf)
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_AbreCupom(tcCnpjCpf)
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno	
	
ENDPROC

*-- abrir cupom fiscal com cliente e endereço
PROCEDURE fpAbreCupomMFD

	PARAMETERS tcCnpjCpf, tcNome, tcEndereco
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_AbreCupomMFD(tcCnpjCpf, tcNome, tcEndereco)
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_AbreCupomMFD(tcCnpjCpf, tcNome, tcEndereco)
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno	
	
ENDPROC


*-- vende item
PROCEDURE fpVendeItem

	PARAMETERS tcCodigo, tcDescricao, tcAliquota, tcTipoQtde, tcQtde, tiCasasDecimais, tcValor, tcTipoDesconto, tcValorDesc 
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_VendeItem(tcCodigo, tcDescricao, tcAliquota, tcTipoQtde, tcQtde, tiCasasDecimais, tcValor, tcTipoDesconto, tcValorDesc)
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_VendeItem(tcCodigo, tcDescricao, tcAliquota, tcTipoQtde, tcQtde, tiCasasDecimais, tcValor, tcTipoDesconto, tcValorDesc)
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)	
	RETURN lnRetorno	
	
ENDPROC

*-- Fecha cupom
PROCEDURE fpFechaCupom

	PARAMETERS tcNomePgto, tcAcresDesc, tcTipoAcresDesc, tcValorAcresDesc, tcValorPago, tcMsgPromocional	
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_FechaCupom(tcNomePgto, tcAcresDesc, tcTipoAcresDesc, tcValorAcresDesc, tcValorPago)
			
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_FechaCupom(tcNomePgto, tcAcresDesc, tcTipoAcresDesc, tcValorAcresDesc, tcValorPago)
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno	
	
ENDPROC

*-- programar alíquota
PROCEDURE fpProgramaaliquota

	PARAMETERS tcAliquota, tnVinculo
	
	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_ProgramaAliquota(tcAliquota, tnVinculo)
			
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_ProgramaAliquota(tcAliquota, tnVinculo)			
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno
	
ENDPROC

*-- Verificar status do cupom giscal
PROCEDURE fpStatusCupomFiscal

	LOCAL lcRetorno
	lcRetorno = SPACE(2)
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_StatusCupomFiscal(@lcRetorno)
			fpRetorno(lnRetorno)
			
		OTHERWISE

	ENDCASE
	
	RETURN lcRetorno
		
ENDPROC

*-- Cancelar cupom fiscal
PROCEDURE fpCancelaCupomFiscal

	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_CancelaCupom()
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_CancelaCupom()			
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno
		
ENDPROC

*-- Cancelar item
PROCEDURE fpCancelaItem

	PARAMETERS tcItem

	LOCAL lnRetorno
	
	DO CASE
	
		CASE gcImpressora = "bematech"
			lnRetorno = Bematech_FI_CancelaItemGenerico(tcItem)
			
		CASE gcImpressora = "epson"

		CASE gcImpressora = "sweda"
			lnRetorno = ECF_CancelaItemGenerico(tcItem)			
			
		OTHERWISE

	ENDCASE
	
	fpRetorno(lnRetorno)
	RETURN lnRetorno
		
ENDPROC
