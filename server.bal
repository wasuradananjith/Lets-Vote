import ballerina/io;
import ballerina/log;
import ballerina/http;

map<http:WebSocketListener> connections;

@http:WebSocketServiceConfig {
    path: "/basic/ws",
    subProtocols: ["xml", "json"]
}

service<http:WebSocketService> basic bind { port: 9090 } {

    int[] poll=[0,0,0,0];
    string ping = "ping";
    byte[] pingData = ping.toByteArray("UTF-8");

    // This resource is triggered after a successful client connection.
    onOpen(endpoint caller) {
        io:println("\nNew client connected");
        io:println("Connection ID: " + caller.id);
        io:println("Negotiated Sub protocol: " + caller.negotiatedSubProtocol);
        io:println("Is connection open: " + caller.isOpen);
        io:println("Is connection secured: " + caller.isSecure);
        connections[caller.id]=caller;
      
    }

    // This resource is triggered when a new text frame is received from a client.

    
    onText(endpoint caller, string text, boolean final) {
  
        io:println("\ntext message: " + text + " & final fragment: " + final);
        int choice=check <int>text;
        poll[choice-1]++;

         broadcast(""+poll[choice-1]);

    }

 

    // This resource is triggered when a client connection is closed from the client side.
    onClose(endpoint caller, int statusCode, string reason) {
        _ = connections.remove(caller.id);
    }

    
}

function broadcast(string text) {
    endpoint http:WebSocketListener caller;
    // Iterate through all available connections in the connections map
    foreach conn in connections {
        caller = conn;
        // Push the text message to the connection
        caller->pushText(text) but {
            error e => log:printError("Error sending message")
        };
    }
}
// function init() {
//     endpoint http:WebSocketListener caller;
//     // Iterate through all available connections in the connections map
//     foreach conn in connections {
//         caller = conn;
//         // Push the text message to the connection
//         int i=0;
//         json jsonobj;
//         while(i<4){
//             jsonobj.i=i;
//         }
//         caller->pushText(jsonobj.toString()) but {
//             error e => log:printError("Error sending message")
//         };
//     }
// }

