module cliperserver.schema.v1.buffer;
import vibe.db.mongo.mongo;
import cliperserver.utils;
import vibe.data.bson;
import mongoschema;
import std.traits,
       std.uuid;

struct Buffer {
  mixin MongoSchema;

  string buffer_id;
  string apikey;
  string stuff_path;
}

Buffer registerBuffer(string apikey,
                      string stuff_path) {
  Buffer buffer;

  buffer.buffer_id  = randomUUID.toString;
  buffer.apikey     = apikey;
  buffer.stuff_path = stuff_path;
  buffer.save;

  return buffer;
}

auto findBuffer(T)(T key) if (isAssociativeArray!T) {
  return findImpl!(Buffer)(key);
}