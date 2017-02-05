module app;
import std.process,
       std.stdio;
import vibe.d;

enum string LATEST_GIT_HASH = import("./version");
import std.string;
private void api_v1_get_version(HTTPServerRequest req, HTTPServerResponse res) {
  res.writeBody(`{"success":"running", "version":"` ~ LATEST_GIT_HASH.chomp ~`"}`, "application/json");
}

shared static this () {
  auto settings = new HTTPServerSettings;
  settings.port = 3017;
  settings.accessLogToConsole = true;

  auto router = new URLRouter;

  router.get("/api/v1/version", &api_v1_get_version);

  listenHTTP(settings, router);
}