Class isc.rabbitmq.Operation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "isc.rabbitmq.OutboundAdapter";

Property Adapter As isc.rabbitmq.OutboundAdapter;

Method OnMessage(request As Ens.StringContainer, response As Ens.Response) As %Status
{
	#Dim sc As %Status = $$$OK
	Set response = ##class(Ens.Response).%New()
	Set sc = ..Adapter.SendMessage(request.StringValue)
	Quit sc
}

}

