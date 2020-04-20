
void send(String action, JSONObject jb) {
  JSONObject request = new JSONObject();
  request.put("action", action);
  request.put("data", jb);

  client.publish(MQTT_topic, request.toString());
}

void doRegister(String restaurantName, Menu menu) {
  JSONObject data = new JSONObject();
  data.put("name", restaurantName);
  data.put("menu", menu.toJson());

  JSONObject request = new JSONObject();
  request.put("action", "register");
  request.put("data", data);

  client.publish(MQTT_topic_web, request.toString());
}

void doDelete(int index) {
  JSONObject data = new JSONObject();
  data.put("index", index);

  send("delete", data);
}

void doAdd(Food f) {
  JSONObject data = new JSONObject();
  data.put("food", f.toJson());

  send("add", data);
}

void doUpdate(int index, Food f) {
  JSONObject data = new JSONObject();
  data.put("index", index);
  data.put("food", f.toJson());

  send("update", data);
}
