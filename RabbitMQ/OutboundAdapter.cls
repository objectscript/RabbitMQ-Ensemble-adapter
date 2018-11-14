Class RabbitMQ.OutboundAdapter Extends (Ens.OutboundAdapter, RabbitMQ.Common)
{

Parameter SETTINGS = "Exchange:Basic";

/// Establish gateway connection and init java API.
Method OnInit() As %Status
{
	Set sc = $$$OK
	Quit:((..JGService="") && ((..JGHost="") || (..JGPort = ""))) $$$ERROR($$$GeneralError,"Specify JGService setting or JGHost and JGPort settings")
	Quit:((..JGService'="") && '##class(Ens.Director).IsItemEnabled(..JGService)) $$$ERROR($$$GeneralError, $$$FormatText("Java Gateway Service: '%1' is down",..JGService))
	Set sc = ..Connect()
	Quit:$$$ISERR(sc) sc
	Set sc = ..ConnectToRabbitMQ()
	Quit sc
}

/// Close connection
Method OnTearDown() As %Status
{
	Do ..API.close()
	Quit $$$OK
}

/// Send message. message can be a string or stream.
Method SendMessage(message As %Stream.Object) As %Status
{
	Set sc = $$$OK
	Set stream = ##class(%Library.GlobalBinaryStream).%New()
	
	If $isObject(message) {
		While 'message.AtEnd {
			Do stream.Write(..EncodeMessageBody(message.Read($$$MaxStringLength)))
		}
	} Else {
		Do stream.Write(..EncodeMessageBody(message))
	}
	
	#Dim attempts As %Integer = 0
	
	While attempts<2 {
		Set attempts = attempts + 1
		Try {
			Do ..API.sendMessage(stream)
			Return sc
		} Catch ex {
			#Dim ex As %Exception.General
			If ($ZE["<ZJGTW>") {
				Set sc = ..IsOpen()
				Set:$$$ISERR(sc) sc = $$$ADDSC(sc, ex.AsStatus())
			} Else {
				Set sc = ex.AsStatus()
			}
			Return:$$$ISERR(sc) sc // quit if reconnect is unsuccessful or we got unknown exception 
		}
	}
	Quit sc
}

/// Send message. message can be a string or stream.
Method SendMessageToQueue(queue As %String, message As %Stream.Object) As %Status
{
	Set sc = $$$OK
	Set stream = ##class(%Library.GlobalBinaryStream).%New()
	
	If $isObject(message) {
		While 'message.AtEnd {
			Do stream.Write(..EncodeMessageBody(message.Read($$$MaxStringLength)))
		}
	} Else {
		Do stream.Write(..EncodeMessageBody(message))
	}
			
	#Dim attempts As %Integer = 0
	
	While attempts<2 {
		Set attempts = attempts + 1
		Try {
			Do ..API.sendMessageToQueue(queue, stream)
			Return sc
		} Catch ex {
			#Dim ex As %Exception.General
			If ($ZE["<ZJGTW>") {
				Set sc = ..IsOpen()
				Set:$$$ISERR(sc) sc = $$$ADDSC(sc, ex.AsStatus())
			} Else {
				Set sc = ex.AsStatus()
			}
			Return:$$$ISERR(sc) sc // quit if reconnect is unsuccessful or we got unknown exception 
		}
	}
	Quit sc
}

Method EncodeMessageBody(body As %String) As %String
{
	If ..Encoding '= "" {
		If $isObject(body) {
			// TODO streams
		} Else {
			Set body = $zcvt(body, "O", ..Encoding)		
		}
	}
	Quit body
}

}

