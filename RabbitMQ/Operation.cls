Class RabbitMQ.Operation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "RabbitMQ.OutboundAdapter";

Property Adapter As RabbitMQ.OutboundAdapter;

Method OnMessage(request As Ens.StringRequest, response As Ens.Response) As %Status
{
	#Dim sc As %Status = $$$OK
	Set response = ##class(Ens.Response).%New()
	quit ..Adapter.SendMessageToQueue("Hello", request.StringValue)
}

}

