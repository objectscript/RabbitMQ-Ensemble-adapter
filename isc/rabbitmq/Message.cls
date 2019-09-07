Class isc.rabbitmq.Message Extends %Persistent
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
Property Body(MAXLEN = "") [ Transient ];

Method BodyGet() [ CodeMode = expression ]
{
$select(..BodyString'="":..BodyString, 1:..BodyStream)
}

/// Body if it's a string
Property BodyString As %String(MAXLEN = "");

/// Body if it's a stream
Property BodyStream As %Stream.GlobalCharacter;

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
<Value name="16">
<Value>BodyString</Value>
</Value>
<Value name="17">
<Value>BodyStream</Value>
</Value>
</Data>
<DataLocation>^isc.rabbitmq.MessageD</DataLocation>
<DefaultData>MessageDefaultData</DefaultData>
<IdLocation>^isc.rabbitmq.MessageD</IdLocation>
<IndexLocation>^isc.rabbitmq.MessageI</IndexLocation>
<StreamLocation>^isc.rabbitmq.MessageS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

