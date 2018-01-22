# RabbitMQ-Ensemble-adapter
Ensemble adapter for RabbitMQ

## Installation

1. Install [java 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html).
2. Build [RabbitMQ-Ensemble-javaapi](https://github.com/intersystems-ru/RabbitMQ-Ensemble-javaapi) or download [latest binary](https://github.com/intersystems-ru/RabbitMQ-Ensemble-javaapi/releases).
3. Create (or use any existing one) Java gateway. To create one go to SMP > System Administration > Configuration > Connectivity > Object Gateways. Remember the `Port` value.
4. Start Java Gateway. 
5. In a terminal in a target namespace execute:
   
   ```  
   Set class = "isc.rabbitmq.API"
   Set classPath = ##class(%ListOfDataTypes).%New()
   Do classPath.Insert(PATH-TO-JAR)
   Set gateway = ##class(%Net.Remote.Gateway).%New() 
   Set sc = gateway.%Connect("localhost", PORT, $Namespace, 2, classPath)
   Set sc = gateway.%Import(class)
   Write ##class(%Dictionary.CompiledClass).%ExistsId(class)
6. In the namespace `isc.rabbitmq.API` class should be present and compiled.
7. Import [this project](https://github.com/intersystems-ru/RabbitMQ-Ensemble-adapter/releases) and compile.
8. For samples refer to the test production `RabbitMQ.Production`.


## Development

Development is done on [Cache-Tort-Git UDL fork](https://github.com/MakarovS96/cache-tort-git)

## Usage

Check `RabbitMQ.Utils` for sample code. The main class is `isc.rabbitmq.API`. It has the following methods.

### Methods

| Method             | Arguments                                           | Returns | Description                                                                                                                 |
|--------------------|-----------------------------------------------------|---------|-----------------------------------------------------------------------------------------------------------------------------|
| %OnNew             | gateway, host, port, user, pass, virtualHost, queue, durable | api     | Creates new connection to RabbitMQ                                                                                          |
| sendMessage        | msg, correlationId, messageId                       | null    | Sends message to default queue (as specified in %OnNew)                                                                     |
| sendMessageToQueue | queue, msg, correlationId, messageId                | null    | Sends message to the specified queue                                                                                        |
| readMessageString  | -                                                   | props   | Reads message from default queue. Returns list of message properties (including message text)                               |
| readMessageStream  | props                                               | msg     | Reads message from default queue. Returns message text as a stream and props is populated with a list of message properties |
| close              | -                                                   | -       | Closes the connection                                                                                                       |

### Arguments

| Argument      | Java type        | InterSystems type   | Value         | Required                                      | Description                             |
|---------------|------------------|---------------------|---------------|-----------------------------------------------|-----------------------------------------|
| gateway       | -                | %Net.Remote.Gateway | -             | Yes                                           | Connection to Java Gateway              |
| host          | String           | %String             | localhost     | Yes                                           | Address of RabbitMQ server              |
| port          | int              | %Integer            | -1            | Yes                                           | RabbitMQ listener port                  |
| user          | String           | %String             | guest         | Yes                                           | Username                                |
| pass          | String           | %String             | guest         | Yes                                           | Password                                |
| virtualHost   | String           | %String             | /             | Yes                                           | Virtual host                            |
| queue         | String           | %String             | Test          | Yes                                           | Queue name                              |
| durable       | int              | %Integer            | 1             | Required only if you want to create new queue | The queue will survive a server restart |
| msg           | byte[]           | %GlobalBinaryStream | Text          | Yes                                           | Message body                            |
| correlationId | String           | %String             | CorrelationId | Required only with messageId                  | Correlation identifier                  |
| messageId     | String           | %String             | MessageId     | Required only with correlationId              | Message identifier                      |
| props         | String[]         | %ListOfDataTypes    | -             | Yes. Should have 15 elements                  | List of message properties              |
| api           | isc.rabbitmq.API | isc.rabbitmq.API    | -             | -                                             | API object                              |

### Initialization

#### Java Gateway

First you need a Java Gateway object (hereinafter: `gateway`). For example you can get it using this method:

```
/// Get JGW object
ClassMethod Connect(gatewayName As %String, path As %String, Output sc As %Status) As %Net.Remote.Gateway
{
	Set gateway = ""
	Set sc = ##class(%Net.Remote.Service).OpenGateway(gatewayName, .gatewayConfig)
	Quit:$$$ISERR(sc) gateway
	Set sc = ##class(%Net.Remote.Service).ConnectGateway(gatewayConfig, .gateway, path, $$$YES)
	Quit gateway
}
```
Where:
- gatewayName - is name of Java Gateway (it would be started automatically)
- path - path to [JAR](https://github.com/intersystems-ru/RabbitMQ-Ensemble-javaapi/releases)

#### RabbitMQ

Now that Java Gateway connection is established we can connect to RabbitMQ:

```
ClassMethod GetAPI(gateway As %Net.Remote.Gateway) As isc.rabbitmq.API
{
	Set host = "localhost"
	Set port = -1
	Set user = "guest"
	Set pass = "guest"
	Set virtualHost = "/"
	Set queue = "Test"
	Set durable = $$$YES
	
	Set api = ##class(isc.rabbitmq.API).%New(gateway, host, port, user, pass, virtualHost, queue, durable)
	Quit api
}
```

All parameters are described in the table above. Note that `durable` argument is used only if you're creating a new queue. If the queue alreay exists you should still provide it (0 or 1) but it won't be used.

### Sending messages

Assuming you already  have `api` object, sending messages can be done by one of two ways:
- sending messages to default queue
- sending messages to specified queue

#### Sending messages to default queue

Default queue is a queue specified during creation of the `api` object. To send a message just call 

```
#Dim api As isc.rabbitmq.API
#Dim msg As %GlobalBinaryStream
Do api.sendMessage(msg, "correlationId", "messageId " _ $zdt($zts,3,1,3))
```

Where `stream` is a message body. You can either provide both `messageId` and `correlationId` or non of them.

#### Sending messages to specified queue

Everything is the same as above, except you call `sendMessageToQueue` method and the first argument is the name of the queue.

### Reading messages

Messages are always read from the default queue (specified at creation of the `api` object). Message body can be received as text or as a stream.

#### Reading message as a stream

First you need to prepare `props` to pass by reference into Java and then call `readMessageStream`:

```
#Dim api As isc.rabbitmq.API
#Dim msg As %GlobalBinaryStream
#Dim props As %ListOfDataTypes
Set props = ##class(%ListOfDataTypes).%New()
For i=1:1:15 Do props.Insert("")
Set msg = api.readMessageStream(.props)
```

`props` would be filled with message metainformation, and `msg` is a stream containig message body. 


#### Reading message as a string

```
#Dim api As isc.rabbitmq.API
#Dim props As %ListOfDataTypes
Set props = api.readMessageString()
```

`props` would be filled with message metainformation and message body, note that you don't need to initialize it on the InterSystems side before calling RabbitMQ.

#### Props

Elements appearing in `props`. All of them besides first and second are optional. Conversion from list into `RabbitMQ.Message` is available in the `ListToMessage` method of `RabbitMQ.InboundAdapter` class.

| Position | Name            | Description                                                   |
|----------|-----------------|---------------------------------------------------------------|
| 1        | Message Length  | Length of a current message                                   |
| 2        | Message Count   | Number of remaining messages                                  |
| 3        | ContentType     |                                                               |
| 4        | ContentEncoding |                                                               |
| 5        | CorrelationId   |                                                               |
| 6        | ReplyTo         |                                                               |
| 7        | Expiration      |                                                               |
| 8        | MessageId       |                                                               |
| 9        | Type            |                                                               |
| 10       | UserId          |                                                               |
| 11       | AppId           |                                                               |
| 12       | ClusterId       |                                                               |
| 13       | DeliveryMode    |                                                               |
| 14       | Priority        |                                                               |
| 15       | Timestamp       |                                                               |
| 16       | Message body    | If message is read as a string, this element would contain it |
