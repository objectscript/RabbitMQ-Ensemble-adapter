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
7. Import this project and compile.
8. For samples refer to the test production `RabbitMQ.Production`.
