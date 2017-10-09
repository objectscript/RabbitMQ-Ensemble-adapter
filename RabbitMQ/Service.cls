Class RabbitMQ.Service Extends Ens.BusinessService
{

Parameter ADAPTER = "RabbitMQ.InboundAdapter";

Property Adapter As RabbitMQ.InboundAdapter;

Method OnProcessInput(message As RabbitMQ.Message) As %Status
{
	quit message.%Save()
}

}

