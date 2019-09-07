Class isc.rabbitmq.Service Extends Ens.BusinessService
{

Parameter ADAPTER = "isc.rabbitmq.InboundAdapter";

Property Adapter As isc.rabbitmq.InboundAdapter;

Method OnProcessInput(message As isc.rabbitmq.Message) As %Status
{
	quit message.%Save()
}

}

