Class RabbitMQ.Message Extends %Persistent
{

Property ContentType As %String;

Property ContentEncoding As %String;

Property CorrelationId As %String;

Property ReplyTo As %String;

Property Expiration As %String;

Property MessageId As %String;

Property Type As %String;

Property UserId As %String;

Property AppId As %String;

Property ClusterId As %String;

Property DeliveryMode As %String;

Property Priority As %String;

Property Timestamp As %String;

/// Could be either string or stream
Property Body As %String;

Storage Default
{
<Data name="MessageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ContentType</Value>
</Value>
<Value name="3">
<Value>ContentEncoding</Value>
</Value>
<Value name="4">
<Value>CorrelationId</Value>
</Value>
<Value name="5">
<Value>ReplyTo</Value>
</Value>
<Value name="6">
<Value>Expiration</Value>
</Value>
<Value name="7">
<Value>MessageId</Value>
</Value>
<Value name="8">
<Value>Type</Value>
</Value>
<Value name="9">
<Value>UserId</Value>
</Value>
<Value name="10">
<Value>AppId</Value>
</Value>
<Value name="11">
<Value>ClusterId</Value>
</Value>
<Value name="12">
<Value>DeliveryMode</Value>
</Value>
<Value name="13">
<Value>Priority</Value>
</Value>
<Value name="14">
<Value>Timestamp</Value>
</Value>
<Value name="15">
<Value>Body</Value>
</Value>
</Data>
<DataLocation>^RabbitMQ.MessageD</DataLocation>
<DefaultData>MessageDefaultData</DefaultData>
<IdLocation>^RabbitMQ.MessageD</IdLocation>
<IndexLocation>^RabbitMQ.MessageI</IndexLocation>
<StreamLocation>^RabbitMQ.MessageS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
