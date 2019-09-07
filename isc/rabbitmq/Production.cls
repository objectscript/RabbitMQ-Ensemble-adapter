Class isc.rabbitmq.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="isc.rabbitmq.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="isc.rabbitmq.Service" Category="" ClassName="RabbitMQ.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="JGService">EnsLib.JavaGateway.Service</Setting>
    <Setting Target="Adapter" Name="ClassPath">C:\InterSystems\RabbitMQjava.jar;C:\InterSystems\Java\amqp-client-5.7.2.jar</Setting>
    <Setting Target="Adapter" Name="Queue">hello</Setting>
    <Setting Target="Adapter" Name="BodyClass"></Setting>
    <Setting Target="Adapter" Name="Encoding">UTF8</Setting>
    <Setting Target="Adapter" Name="CallInterval">1</Setting>
  </Item>
  <Item Name="EnsLib.JavaGateway.Service" Category="" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Port">55559</Setting>
    <Setting Target="Host" Name="JDKVersion">JDK18</Setting>
    <Setting Target="Host" Name="JavaHome">C:\Progra~1\Java\jdk1.8.0_121\</Setting>
    <Setting Target="Host" Name="ClassPath">C:\InterSystems\RabbitMQjava.jar;C:\InterSystems\Java\amqp-client-5.7.2.jar</Setting>
  </Item>
  <Item Name="isc.rabbitmq.Operation" Category="" ClassName="RabbitMQ.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="JGService">EnsLib.JavaGateway.Service</Setting>
    <Setting Target="Adapter" Name="Queue">hello</Setting>
    <Setting Target="Adapter" Name="ClassPath">C:\InterSystems\RabbitMQjava.jar;C:\InterSystems\Java\amqp-client-5.7.2.jar</Setting>
    <Setting Target="Adapter" Name="Encoding">UTF8</Setting>
  </Item>
</Production>
}

}

