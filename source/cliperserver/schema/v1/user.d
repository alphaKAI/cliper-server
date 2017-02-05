module cliperserver.schema.v1.user;
import vibe.db.mongo.mongo;
import cliperserver.utils;
import vibe.data.bson;
import mongoschema;
import std.traits,
       std.uuid;

struct User {
  mixin MongoSchema;

  string apikey;

  string current_buffer_id;
}

User registerUser() {
  User user;

  user.apikey = randomUUID.toString;
  user.current_buffer_id = "NULL";
  user.save;

  return user;
}

auto findUser(T)(T key) if (isAssociativeArray!T) {
  return findImpl!(User)(key);
}