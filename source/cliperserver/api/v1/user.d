module cliperserver.api.v1.user;
import cliperserver.schema.v1.buffer,
       cliperserver.schema.v1.user;
import cliperserver.utils;
import mongoschema;
import vibe.d;
import std.stdio,
       std.file;

void api_v1_post_users(HTTPServerRequest req, HTTPServerResponse res) {
  auto user     = registerUser;
  string apikey = user.apikey;

  if (!exists("users")) {
    mkdir("users");
  }

  mkdir("users/" ~ apikey);

  Response!(string, "apikey") resp;

  resp.apikey = apikey;

  res.return_success(resp);
}

/*
# [GET] /users
## HTTP Request Header
|Parameter|Description|
|---------|-----------|
|apikey|apikey of the user|
## Response
|Parameter|Description|
|---------|-----------|
|status|0: success, 1: failure|
|buffer|base64 encoded payload|
|error|error_msg|
*/
void api_v1_get_users(HTTPServerRequest req, HTTPServerResponse res) {
  if (req.headers.header_has_all_keys(["apikey"])) {
    string apikey = req.headers["apikey"];
    auto   user   = findUser(["apikey":apikey]);

    if (user.isNull) {
      Response!(string, "error") resp;
      resp.status = 1;
      resp.error  = "Unauthorized";
      res.return_error(resp);
    } else {
      string buffer_id = user.current_buffer_id;

      if (buffer_id == "NULL") {
        Response!(string, "error") resp;
        resp.status = 1;
        resp.error  = "There is no buffer";
        res.return_error(resp); 
      } else {
        auto buffer = findBuffer(["buffer_id":buffer_id]);
        if (buffer.isNull) {
          Response!(string, "error") resp;
          resp.status = 1;
          resp.error  = "Invalid buffer_id was given";
          res.return_error(resp);
        } else {
          import std.base64;
          string stuff_path = buffer.stuff_path;
          auto file = File(stuff_path, "rb");
          ubyte[] buf;
          buf.length = file.size;
          file.rawRead(buf);

          string b64_encoded_payload = Base64.encode(buf);

          Response!(string, "buffer") resp;
          resp.buffer = b64_encoded_payload;
          res.return_success(resp);
        }
      }
    }
  } else {
    Response!(string, "error") resp;
    resp.status = 1;
    resp.error  = "Unauthorized";
    res.return_error(resp);
  }
}