import mongoschema;
import std.typecons,
        std.format,
        std.range;
import vibe.d;

void return_success(T)(HTTPServerResponse res, T payload, int status = 0) {
  res.writeBody(payload.serializeToJson.toString, "application/json");
}

void return_success(HTTPServerResponse res, int status = 0) {
  CustomStruct!(int, "status") resp;
  resp.status = status;
  res.writeBody(resp.serializeToJson.toString, "application/json");
}

void return_error(HTTPServerResponse res, int errno, int status = 1) {
  res.statusCode = 400;
  Response!(int, "errno") resp;
  resp.status = status;
  resp.errno  = errno;
  res.writeBody(resp.serializeToJson.toString, "application/json");
}
/**
 * This function finds an data by keys.
 * This function returns:
 *     Found : found value
 * Not Found : Null(with Nullable!(User).init)
 */
Nullable!Type findImpl(Type)(string[string] keys) {
  try {
    return Nullable!(Type)(Type.findOne(keys));
  } catch (Exception) {
    return Nullable!(Type).init;
  }
}

static string generateDeclarations(Members...)() {
  static assert(Members.length % 2 == 0);

  string[] types;
  string[] names;
  string code;

  size_t idx;

  foreach (elem; Members) {
    if (idx % 2 == 0) { types ~= elem.stringof; }
    else {
      static if (is(elem)) { names ~= elem.stringof; }
              else          { names ~= elem; }
    }
    idx++;
  }

  assert (types.length == names.length);

  foreach (type, name; zip(types, names)) { code ~= "%s %s;".format(type, name); }

  return code;
}

struct CustomStruct(Members...) {
  mixin (generateDeclarations!(Members));
}

struct Response(T, string name) {
  mixin(generateDeclarations!(int, "status"));
  mixin("T " ~ name ~ ";");
}