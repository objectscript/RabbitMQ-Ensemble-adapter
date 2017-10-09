Class RabbitMQ.InboundAdapter Extends (Ens.InboundAdapter, RabbitMQ.Common)
{

/// Stream class to store message body. Leave empty to use strings.
Property BodyClass As %Dictionary.CacheClassname;

Parameter SETTINGS = "BodyClass:Basic";

/// Establish gateway connectionand init java API 
Method OnInit() As %Status
{
	Set sc = $$$OK
	Quit:..JGService="" $$$ERROR($$$GeneralError,"Specify JGService setting")
	Quit:'##class(Ens.Director).IsItemEnabled(..JGService) $$$ERROR($$$GeneralError, $$$FormatText("Java Gateway Service: '%1' is down",..JGService))
	Set sc = ..Connect()
	Quit:$$$ISERR(sc)
	Set sc = ..ConnectToRabbitMQ()
	Quit sc
}

/// Close connection
Method OnTearDown() As %Status
{
	Do ..API.close()
	Quit $$$OK
}

/// default InboundAdapter behavior: always call ProcessInput on CallInterval
Method OnTask() As %Status
{
	Set sc = $$$OK
	
	Set messageCount = 1
	
	While messageCount > 0 {
		#Dim messageList As %ListOfDataTypes 
		
		If ..BodyClass = "" {
			Set messageList = ..API.readMessageString()
		} Else {
			Set tempStream = ..GetTempStream()
			Set messageList = ..API.readMessageStream(.tempStream)
		}
		
		Set messageLength = messageList.GetAt(1)
		Set messageCount = messageList.GetAt(2)
		
		If messageLength>0 {
			#Dim message As RabbitMQ.Message
			Set message = ..ListToMessage(messageList)
			If ..BodyClass = "" {
				Set message.Body = ..DecodeMessageBody(messageList.GetAt(16))
			} Else {
				Set message.Body = $classmethod(..BodyClass, "%New")
				Do message.Body.Write(..DecodeMessageBody(tempStream.Read(messageLength)))
				Do message.Body.Rewind()
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

Method DecodeMessageBody(body As %String) As %String
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

ClassMethod GetTempStream() As %GlobalBinaryStream
{
	Set stream=##class(%GlobalBinaryStream).%New()
    // TODO - work around that
    // we need to 'reserve' a number of bytes since we are passing the stream
    // by reference (Java's equivalent is byte[] ba = new byte[max];)
    For i=1:1:32000 Do stream.Write("0")
    Quit stream
}

}

