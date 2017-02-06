module cliperserver.api.v1.buffer;
import cliperserver.schema.v1.buffer,
       cliperserver.schema.v1.user;
import cliperserver.utils;
import mongoschema;
import vibe.d;
import std.digest.sha,
       std.stdio,
       std.conv,
       std.file,
       std.uuid,
       std.zlib;

/*
# [POST] /buffers
## HTTP Request Header
|Parameter|Description|
|---------|-----------|
|apikey|apikey of the user|
## Response
|Parameter|Description|
|---------|-----------|
|status|0: success, 1: failure|
|buffer_id|buffer_id|
|error|error_msg|
*/
void api_v1_post_buffers(HTTPServerRequest req, HTTPServerResponse res) {
  if (req.headers.header_has_all_keys(["apikey"])) {
    string apikey = req.headers["apikey"];
    auto user = findUser(["apikey":apikey]);

    if (user.isNull) {
      Response!(string, "error") resp;
      resp.status = 1;
      resp.error  = "Unauthorized";
      res.return_error(resp);
    } else {
      if (!req.bodyReader.dataAvailableForRead) {
        Response!(string, "error") resp;
        resp.status = 1;
        resp.error  = "Empty payload was given";
        res.return_error(resp);
      } else {
        ubyte[] buf;
        buf.length = req.bodyReader.leastSize;
        req.bodyReader.read(buf);

        string stuff_path = "users/" ~ apikey ~ "/" ~ sha1Of(buf).toHexString.to!string;

        if (!exists(stuff_path)) {
          auto file = File(stuff_path, "wb");
          file.rawWrite(buf);
        }

        auto buffer = registerBuffer(apikey, stuff_path);
        user.current_buffer_id = buffer.buffer_id;
        user.save;

        Response!(string, "buffer_id") resp;
        resp.buffer_id = buffer.buffer_id;
        res.return_success(resp);
      }
    }
  } else {
    Response!(string, "error") resp;
    resp.status = 1;
    resp.error  = "Unauthorized";
    res.return_error(resp);
  }
}

/*
# [GET] /buffers/:buffer_id
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
void api_v1_get_buffers(HTTPServerRequest req, HTTPServerResponse res) {
  if (req.headers.header_has_all_keys(["apikey"])) {
    string apikey    = req.headers["apikey"];
    string buffer_id = req.params["buffer_id"];
    auto user = findUser(["apikey":apikey]);

    if (user.isNull) {
      Response!(string, "error") resp;
      resp.status = 1;
      resp.error  = "Unauthorized";
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
  } else {
    Response!(string, "error") resp;
    resp.status = 1;
    resp.error  = "Unauthorized";
    res.return_error(resp);
  }
}