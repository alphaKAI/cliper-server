module app;
import std.process,
       std.stdio;
import vibe.d;
import mongoschema;
import cliperserver.schema.v1.buffer,
       cliperserver.schema.v1.user;
import cliperserver.api.v1.buffer,
       cliperserver.api.v1.user;

enum string LATEST_GIT_HASH = import("./version");
import std.string;
private void api_v1_get_version(HTTPServerRequest req, HTTPServerResponse res) {
  res.writeBody(`{"success":"running", "version":"` ~ LATEST_GIT_HASH.chomp ~`"}`, "application/json");
}

shared static this () {
  auto settings = new HTTPServerSettings;
  settings.port = 3017;
  settings.accessLogToConsole = true;

  immutable string CLIPER_SERVER_MONGO_DSN = environment.get("CLIPER_SERVER_MONGO_DSN");
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