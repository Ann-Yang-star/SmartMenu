
String MQTT_topic = "food_orders";
String MQTT_topic_web = "food_orders_web";

void clientConnected() {
  println("client connected to broker");
  client.subscribe(MQTT_topic);
}

void connectionLost() {
  println("connection lost");
}

void sendMenuToWeb() {
  Restaurant res = loadRestaurant();

  JSONObject json = new JSONObject();
  json.put("resName", res.name);
  json.put("resID", res.id);
  json.put("menuSize", menu.size());
  json.put("menu", menu.toJson());

  JSONObject request = new JSONObject();
  request.put("action", "update");
  request.put("data", json);

  client.publish(MQTT_topic_web, request.toString());
}

void messageReceivedProcessing(byte[] payload) {
  JSONObject json = parseJSONObject(new String(payload));
  if (json == null) {
    println("Json could not be parsed");
  } else {
    println(json.toString());
    String action = json.getString("action");
    JSONObject data = json.getJSONObject("data");

    if (action.equals("register")) {
      //register
      String name = data.getString("name");
      String id = data.getString("id");

      Restaurant res = new Restaurant(name, id);
      saveJSONObject(res.toJson(), pathRestaurant);

      view.toView(ViewType.OrderList);
      view.update();
    } else if (action.equals("delete")) {
      //delete order
      int index = data.getInt("index");
      menu.remove(index);
      saveJSONArray(menu.toJson(), pathMenu);

      view.update();
    } else if (action.equals("add")) {
      //add order
      JSONObject foodJson = data.getJSONObject("food");
      Food f = new Food(foodJson);
      menu.addFood(f);
      saveJSONArray(menu.toJson(), pathMenu);

      view.toView(ViewType.OrderList);
      view.update();
    } else if (action.equals("update")) {
      //add order
      int index = data.getInt("index");
      JSONObject foodJson = data.getJSONObject("food");
      Food f = new Food(foodJson);
      menu.set(index, f);
      saveJSONArray(menu.toJson(), pathMenu);

      view.toView(ViewType.OrderList);
      view.update();
    }

    sendMenuToWeb();
  }
}

void messageReceived(String topic, byte[] payload) {
  println("Message Received: " + topic);
  messageReceivedProcessing(payload);
}
