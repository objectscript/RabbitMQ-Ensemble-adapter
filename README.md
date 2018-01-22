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

## Use

Check `RabbitMQ.Utils` for sample code. The main class is `isc.rabbitmq.API`. It has the following methods.

| Method             | Arguments                                           | Returns | Description                                                                                                                 |
|--------------------|-----------------------------------------------------|---------|-----------------------------------------------------------------------------------------------------------------------------|
| %OnNew             | host, port, user, pass, virtualHost, queue, durable | api     | Creates new connection to RabbitMQ                                                                                          |
| sendMessage        | msg, correlationId, messageId                       | null    | Sends message to default queue (as specified in %OnNew)                                                                     |
| sendMessageToQueue | queue, msg, correlationId, messageId                | null    | Sends message to the specified queue                                                                                        |
| readMessageString  | -                                                   | result  | Reads message from default queue. Returns list of message properties (including message text)                               |
| readMessageStream  | result                                              | msg     | Reads message from default queue. Returns message text as array and result - is populated with a list of message properties |
| close              | -                                                   | -       | Closes the connection                                                                                                       |

Arguments:

| Argument      | Java type        | InterSystems type   | Value         | Required                                      | Description                             |
|---------------|------------------|---------------------|---------------|-----------------------------------------------|-----------------------------------------|
| host          | String           | %String             | localhost     | Yes                                           | Address of RabbitMQ server              |
| port          | int              | %Integer            | -1            | Yes                                           | RabbitMQ listener port                  |
| user          | String           | %String             | guest         | Yes                                           | Username                                |
| pass          | String           | %String             | guest         | Yes                                           | Password                                |
| virtualHost   | String           | %String             | /             | Yes                                           | Virtual host                            |
| queue         | String           | %String             | Test          | Yes                                           | Queue name                              |
| durable       | int              | %Integer            | 1             | Required only if you want to create new queue | The queue will survive a server restart |
| msg           | byte[]           | %GlobalBinaryStream | Text          | Yes as argument                               | Message body                            |
| correlationId | String           | %String             | CorrelationId | Required only with messageId                  | Correlation identifier                  |
| messageId     | String           | %String             | MessageId     | Required only with correlationId              | Message identifier                      |
| result        | String[]         | %ListOfDataTypes    | -             | Yes as argument. Should have 16 elements      | List of message properties              |
| api           | isc.rabbitmq.API | isc.rabbitmq.API    | -             | -                                             | API object                              |
