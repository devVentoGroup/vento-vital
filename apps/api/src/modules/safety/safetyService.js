export class SafetyService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  submitIntake({ token, payload }) {
    return this.rpc.call("submit_safety_intake", { p_payload: payload || {} }, token);
  }

  getStatus({ token }) {
    return this.rpc.call("get_safety_status", {}, token);
  }
}
