import mqtt.*;
import controlP5.*;

String MQTT_topic_web = "food_orders_web";
String MQTT_topic = "food_orders";

ControlP5 cp5;
MQTTClient client;
Textarea text;

void setup() {
  cp5 = new ControlP5(this);
  size(900, 700);

  // connect to the broker
  client = new MQTTClient(this);
  // connect to the broker and use a random string for clientid
  client.connect("mqtt://try:try@broker.hivemq.com", "processing_web" + str(random(3)));
  delay(100);

  final PFont font = createFont("Times", 23);
  text = cp5.addTextarea("text")
    .setFont(font)
    .setPosition(10, 10)
    .setSize(800, 650);
}

void clientConnected() {
  println("client connected to broker");
  client.subscribe(MQTT_topic_web);
}

void connectionLost() {
  println("connection lost");
}

void messageReceived(String topic, byte[] payload) {
  
  JSONObject json = parseJSONObject(new String(payload));
  println("JSON Received:\n" + json.toString());
  text.setText(text.getText() + "\n\nJSON Received:\n" + json.toString());


  String action = json.getString("action");
  JSONObject data = json.getJSONObject("data");

  if (action.equals("register")) {
    //register

    String restaurentName = data.getString("name");
    JSONArray menu = data.getJSONArray("menu");

    //generate id
    String id = "restaurant" + (int)random(1, 100);

    
    JSONObject res = new JSONObject();
    res.put("name", restaurentName);
    res.put("id", id);
    
    JSONObject response = new JSONObject();
    response.put("action", "register");
    response.put("data", res);

    client.publish(MQTT_topic, response.toString());

    println("JSON Send:\n" + response.toString());
    text.setText(text.getText() + "\n\nJSON Send:\n" + response.toString());
  } else if (action.equals("update")) {
    //update menu
  }
}

// we don't really use the draw function as controlP5 does the work
void draw() {
  background(0);
}
