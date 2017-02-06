module app;
import cliperserver.schema.v1.buffer,
       cliperserver.schema.v1.user;
import cliperserver.api.v1.buffer,
       cliperserver.api.v1.user;
import std.process,
       std.string,
       std.stdio,
       std.conv;
import mongoschema;
import vibe.d;

enum string LATEST_GIT_HASH = import("./version");
private void api_v1_get_version(HTTPServerRequest req, HTTPServerResponse res) {
  res.writeBody(`{"success":"running", "version":"` ~ LATEST_GIT_HASH.chomp ~`"}`, "application/json");
}

enum DEFAULT_PORT = 3017;

shared static this () {

  immutable string CLIPER_SERVER_PORT      = environment.get("CLIPER_SERVER_PORT");
  immutable string CLIPER_SERVER_MONGO_DSN = environment.get("CLIPER_SERVER_MONGO_DSN");

  auto settings = new HTTPServerSettings;
  settings.accessLogToConsole = true;

  if (CLIPER_SERVER_PORT is null) {
    settings.port = DEFAULT_PORT;
  } else {
    settings.port = CLIPER_SERVER_PORT.to!ushort;
  }

  if (CLIPER_SERVER_MONGO_DSN is null) {
    throw new Error("Please set $CLIPER_SERVER_MONGO_DSN in environment variable.");
  }

  auto client = connectMongoDB(CLIPER_SERVER_MONGO_DSN);

  client.getCollection("cliperserver.users").register!User;
  client.getCollection("cliperserver.buffers").register!Buffer;

  auto router = new URLRouter;

  router.get("/api/v1/version", &api_v1_get_version);
  router.post("/api/v1/users", &api_v1_post_users);
  router.get("/api/v1/users", &api_v1_get_users);
  router.post("/api/v1/buffers", &api_v1_post_buffers);
  router.get("/api/v1/buffers/:buffer_id", &api_v1_get_buffers);

  listenHTTP(settings, router);
}