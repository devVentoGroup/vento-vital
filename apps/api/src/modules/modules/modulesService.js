import { createHttpError } from "../../lib/http.js";

export class ModulesService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  listCatalog({ token }) {
    return this.rpc.call("list_module_catalog", {}, token);
  }

  getMine({ token }) {
    return this.rpc.call("get_user_module_preferences", {}, token);
  }

  updateMine({ token, modules }) {
    if (!Array.isArray(modules)) {
      throw createHttpError(400, "modules must be an array");
    }
    return this.rpc.call("upsert_user_module_preferences", { p_modules: modules }, token);
  }
}
