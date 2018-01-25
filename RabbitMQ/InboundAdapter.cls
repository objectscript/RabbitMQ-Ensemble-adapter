Class RabbitMQ.InboundAdapter Extends (Ens.InboundAdapter, RabbitMQ.Common)
{

/// Stream class to store message body. Leave empty to use strings.
Property BodyClass As %Dictionary.CacheClassname;

Parameter SETTINGS = "BodyClass:Basic";

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

/// Close connection.
Method OnTearDown() As %Status
{
	Do ..API.close()
	Quit $$$OK
}

/// Get Messages from RabbitMQ queue.
Method OnTask() As %Status
{
	Set sc = $$$OK
	
	Set messageCount = 1
	
	While messageCount > 0 {
		// List containing metainformation and possibly body (in the case of string interaction) of the RabbitMQ message 
		#Dim messageList As %ListOfDataTypes 
		
		If ..BodyClass = "" {
			Set messageList = ..API.readMessageString()
		} Else {
			#Dim tempStream As %Library.GlobalBinaryStream
			Set messageList = ##class(%ListOfDataTypes).%New()
			For i=1:1:15 Do messageList.Insert("")
			Set tempStream = ..API.readMessageStream(.messageList)
		}
		
		Set messageLength = messageList.GetAt(1)
		Set messageCount = messageList.GetAt(2)
		
		If messageLength>0 {
			#Dim message As RabbitMQ.Message
			Set message = ..ListToMessage(messageList)
			If ..BodyClass = "" {
				Set message.BodyString = ..DecodeMessageBody(messageList.GetAt(16))
			} Else {
				Set message.BodyStream = $classmethod(..BodyClass, "%New")
				While 'tempStream.AtEnd {
					Do message.BodyStream.Write(..DecodeMessageBody(tempStream.Read($$$MaxStringLength)))
				}
				Do message.BodyStream.Rewind()
			}
			Set sc = ..BusinessHost.ProcessInput(message)
		} Else {
			CONTINUE
		}		
		Quit:$$$ISERR(sc)
	}
	Set ..BusinessHost.%WaitForNextCallInterval=1
	Quit sc
}

/// Convert list containing metainformation into RabbitMQ message
ClassMethod ListToMessage(list As %ListOfDataTypes) As RabbitMQ.Message
{
	Set message = ##class(RabbitMQ.Message).%New()
	
	Set message.ContentType = list.GetAt(3)
	Set message.ContentEncoding = list.GetAt(4)
	Set message.CorrelationId = list.GetAt(5)
	Set message.ReplyTo = list.GetAt(6)
	Set message.Expiration = list.GetAt(7)
	Set message.MessageId = list.GetAt(8)
	Set message.Type = list.GetAt(9)
	Set message.UserId = list.GetAt(10)
	Set message.AppId = list.GetAt(11)
	Set message.ClusterId = list.GetAt(12)
	Set message.DeliveryMode = list.GetAt(13)
	Set message.Priority = list.GetAt(14)
	Set message.Timestamp = list.GetAt(15)

	Quit message
}

/// Decode message body. May be full body or only a piece. 
Method DecodeMessageBody(body As %String) As %String
{
	Set:..Encoding'="" body = $zcvt(body, "I", ..Encoding)
	Quit body
}

}

